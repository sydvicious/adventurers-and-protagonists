//
//  CombatModeView.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

/// Combat mode (vision §5c): a distinct player-side HUD for running a fight from the
/// character — separate from the Phase 2 GM combat tracker. Pushed onto the navigation
/// stack (not modal). This v1 works with the basic-combatant data: initiative, HP,
/// defenses, saving-throw and ability-check rolls, a one-tap held-weapon roll, and the
/// attacks list with to-hit and damage rolls. The Cast / Use item / Use skill action
/// bar, active-effect round counters, class resources, action-economy tracking, and
/// campaign auto-entry are deferred to later subsystems/phases (see TODO.md).
struct CombatModeView: View {
    @Bindable var adventurer: Adventurer
    /// Persistent per-character combat state (round, modifiers, hands, …) from the store.
    @Bindable var session: CombatSession

    @State private var rollResult: RollResult?
    @State private var contentWidth: CGFloat = 0

    var body: some View {
        ScrollView {
            Group {
                if isWide {
                    wideLayout
                } else {
                    narrowLayout
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { contentWidth = $0 }
        .onAppear(perform: seedHands)
        .navigationTitle("Combat")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Round \(session.round)").font(.headline).monospacedDigit()
            }
            ToolbarItem(placement: .primaryAction) {
                Button("End my turn", action: endTurn)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("End combat", action: endCombat)
            }
        }
        .sheet(item: $rollResult) { result in
            RollResultView(result: result)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Layout

    /// Two columns once the HUD is wide enough (iPad / Mac); iPhone stays single-column.
    private var isWide: Bool { contentWidth >= 700 }

    @ViewBuilder
    private var narrowLayout: some View {
        VStack(spacing: 16) {
            statusCard
            hitPointsCard
            toHitCard
            defensesCard
            savingThrowsCard
            if !adventurer.abilities.isEmpty { abilityChecksCard }
        }
    }

    /// Status spans the full width; the rest flows into two columns. Ability checks stay
    /// within a column rather than spanning across.
    @ViewBuilder
    private var wideLayout: some View {
        VStack(spacing: 16) {
            statusCard
            HStack(alignment: .top, spacing: 16) {
                VStack(spacing: 16) {
                    hitPointsCard
                    toHitCard
                }
                VStack(spacing: 16) {
                    defensesCard
                    savingThrowsCard
                    if !adventurer.abilities.isEmpty { abilityChecksCard }
                }
            }
        }
    }

    // MARK: - Status

    private var statusCard: some View {
        GroupBox {
            HStack(alignment: .firstTextBaseline) {
                Text(adventurer.name)
                    .font(.title3.bold())
                Spacer()
                labelledValue("Initiative", "\(session.initiativeRoll)", alignment: .trailing)
            }
        }
    }

    private func labelledValue(_ caption: String, _ value: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title, design: .rounded).weight(.bold))
                .monospacedDigit()
        }
    }

    // MARK: - To Hit (PF1e flat modifiers that affect rolls)

    /// Flanking applies to attack rolls only; the situational modifier applies to every
    /// d20 roll (to-hit, saves, ability checks).
    private var toHitCard: some View {
        CollapsiblePanel("To Hit") {
            VStack(spacing: 12) {
                Toggle("Flanking (+2 attack)", isOn: $session.flanking)
                Stepper(value: $session.situational, in: -20...20) {
                    HStack {
                        Text("Situational modifier")
                        Spacer()
                        Text(DiceRoller.signed(session.situational))
                            .monospacedDigit()
                            .foregroundStyle(session.situational == 0 ? .secondary : .primary)
                    }
                }
                Divider()
                handRow(name: "Primary Hand", rollLabel: "Primary", selection: $session.primaryWeaponID)
                handRow(name: "Off-Hand", rollLabel: "Off-Hand", selection: $session.offHandWeaponID)
            }
        }
    }

    /// One hand: a weapon picker (choices are the character's attacks — a stand-in for
    /// inventory weapons until equipment ships) and a button that rolls it.
    private func handRow(name: String, rollLabel: String, selection: Binding<PersistentIdentifier?>) -> some View {
        let weapon = attack(for: selection.wrappedValue)
        return VStack(spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Picker(name, selection: selection) {
                    Text("None").tag(PersistentIdentifier?.none)
                    ForEach(adventurer.sortedAttacks) { attack in
                        Text(attack.displayName).tag(Optional(attack.persistentModelID))
                    }
                }
                .labelsHidden()
            }
            if let weapon {
                Text(weapon.summaryLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                if let weapon {
                    rollResult = weapon.weaponRoll(handLabel: name, extras: attackExtras)
                }
            } label: {
                Text(rollLabel).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(weapon == nil)
        }
    }

    private func attack(for id: PersistentIdentifier?) -> Attack? {
        guard let id else { return nil }
        return adventurer.attacks.first { $0.persistentModelID == id }
    }

    /// Defaults the primary hand to the character's held weapon the first time the HUD
    /// appears. The off-hand starts empty.
    private func seedHands() {
        if session.primaryWeaponID == nil {
            session.primaryWeaponID = adventurer.heldWeapon?.persistentModelID
        }
    }

    /// Named modifiers applied to attack rolls (flanking + any situational modifier).
    private var attackExtras: [RollModifier] {
        var extras: [RollModifier] = []
        if session.flanking {
            extras.append(RollModifier(label: "flanking", value: 2))
        }
        if session.situational != 0 {
            extras.append(RollModifier(label: "situational", value: session.situational))
        }
        return extras
    }

    // MARK: - Hit points

    private var hitPointsCard: some View {
        HitPointsPanel(adventurer: adventurer)
    }

    // MARK: - Defenses

    private var defensesCard: some View {
        CollapsiblePanel("Defenses") {
            HStack {
                defenseColumn("AC", adventurer.armorClass)
                Divider()
                defenseColumn("Touch", adventurer.touchAC)
                Divider()
                defenseColumn("Flat-footed", adventurer.flatFootedAC)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func defenseColumn(_ caption: String, _ value: Int) -> some View {
        VStack(spacing: 2) {
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.title2.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Saving throws (tap to roll d20 + bonus)

    private var savingThrowsCard: some View {
        CollapsiblePanel("Saving Throws") {
            HStack(spacing: 8) {
                rollChip("Fortitude", DiceRoller.signed(adventurer.fortitude)) {
                    rollResult = DiceRoller.check(title: "Fortitude save", modifier: adventurer.fortitude, situational: session.situational)
                }
                rollChip("Reflex", DiceRoller.signed(adventurer.reflex)) {
                    rollResult = DiceRoller.check(title: "Reflex save", modifier: adventurer.reflex, situational: session.situational)
                }
                rollChip("Will", DiceRoller.signed(adventurer.will)) {
                    rollResult = DiceRoller.check(title: "Will save", modifier: adventurer.will, situational: session.situational)
                }
            }
        }
    }

    // MARK: - Ability checks (tap to roll d20 + modifier)

    private var abilityChecksCard: some View {
        CollapsiblePanel("Ability Checks") {
            ColumnGrid(items: Ability.sortedByLabel(abilities: adventurer.abilities)) { ability in
                let modifier = Ability.modifier(value: ability.score)
                rollChip(Self.abbreviation(for: ability.label), DiceRoller.signed(modifier)) {
                    rollResult = DiceRoller.check(title: "\(ability.label) check", modifier: modifier, situational: session.situational)
                }
            }
        }
    }

    private static func abbreviation(for label: String) -> String {
        String(label.prefix(3)).uppercased()
    }

    /// A small two-line button: a name and its modifier. Used for saves and ability checks.
    private func rollChip(_ title: String, _ modifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(modifier)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
    }

    // MARK: - End turn

    private func endTurn() {
        // Advances the player's round counter. Future hooks: tick down active-effect
        // round counters here, and (campaign-attached) notify the GM over sync.
        session.round += 1
    }

    /// Ends the combat session. The Combat tab then shows its "Roll Initiative" start
    /// prompt again; switching tabs (without ending) leaves the session running.
    private func endCombat() {
        session.isRunning = false
    }
}

#if DEBUG
#Preview {
    let session = CombatSession()
    session.start(initiative: 18)
    return NavigationStack {
        CombatModeView(adventurer: .preview, session: session)
    }
    .modelContainer(previewContainer)
}
#endif
