//
//  AdventurerView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//  Copyright ©2024-2026 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

/// The Phase-1 "basic combatant" character sheet: a scrolling stack of grouped
/// cards (HP, defenses, abilities, saves, combat, attacks, notes). HP is
/// adjustable in place; attacks roll a d20. Editing opens the transcribe editor.
struct AdventurerView: View {
    @Bindable var adventurer: Adventurer

    @State private var editorShowing = false
    @State private var rollResult: AttackRollResult?

    init(selection: Adventurer) {
        self.adventurer = selection
    }

    var body: some View {
        Form {
            headerSection
            hitPointsSection
            defensesSection
            abilitiesSection
            savesSection
            combatSection
            if !adventurer.attacks.isEmpty {
                attacksSection
            }
            if !adventurer.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                notesSection
            }
        }
        .formStyle(.grouped)
        #if os(iOS)
        .navigationTitle(adventurer.name)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem {
                Button(action: { editorShowing = true }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $editorShowing) {
            CharacterEditorView(editing: adventurer)
        }
        .alert("Attack roll", isPresented: rollAlertBinding, presenting: rollResult) { _ in
            Button("OK", role: .cancel) { rollResult = nil }
        } message: { result in
            Text(result.message)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 2) {
                Text(adventurer.name)
                    .font(.title2.bold())
                if !adventurer.headerSubtitle.isEmpty {
                    Text(adventurer.headerSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Hit points

    private var hitPointsSection: some View {
        Section("Hit points") {
            VStack(spacing: 12) {
                HStack {
                    Text("Current / Max")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Temp \(adventurer.tempHP)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    hpStepButton(systemImage: "minus", label: "Damage", action: applyDamage)
                    VStack(spacing: 0) {
                        Text("\(adventurer.currentHP)")
                            .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                            .monospacedDigit()
                        Text("/ \(adventurer.maxHP)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                    hpStepButton(systemImage: "plus", label: "Heal", action: applyHeal)
                }

                ProgressView(value: hpFraction)
                    .tint(.green)

                Stepper("Temp HP: \(adventurer.tempHP)", value: $adventurer.tempHP, in: 0...999)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
    }

    private func hpStepButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .accessibilityLabel(label)
    }

    private var hpFraction: Double {
        guard adventurer.maxHP > 0 else { return 0 }
        return min(1, max(0, Double(adventurer.currentHP) / Double(adventurer.maxHP)))
    }

    private func applyDamage() {
        adventurer.currentHP = max(0, adventurer.currentHP - 1)
    }

    private func applyHeal() {
        adventurer.currentHP = min(adventurer.maxHP, adventurer.currentHP + 1)
    }

    // MARK: - Defenses

    private var defensesSection: some View {
        Section("Defenses") {
            StatGrid(stats: [
                StatGrid.Stat(caption: "AC", value: "\(adventurer.armorClass)"),
                StatGrid.Stat(caption: "Touch", value: "\(adventurer.touchAC)"),
                StatGrid.Stat(caption: "Flat-footed", value: "\(adventurer.flatFootedAC)"),
            ])
        }
    }

    // MARK: - Ability scores

    private var abilitiesSection: some View {
        Section("Ability scores") {
            StatGrid(stats: Ability.sortedByLabel(abilities: adventurer.abilities).map { ability in
                StatGrid.Stat(
                    caption: Self.abbreviation(for: ability.label),
                    value: "\(ability.score)",
                    detail: Ability.modifierString(value: ability.score))
            })
        }
    }

    private static func abbreviation(for label: String) -> String {
        String(label.prefix(3)).uppercased()
    }

    // MARK: - Saving throws

    private var savesSection: some View {
        Section("Saving throws") {
            statRow("Fortitude", Attack.signed(adventurer.fortitude))
            statRow("Reflex", Attack.signed(adventurer.reflex))
            statRow("Will", Attack.signed(adventurer.will))
        }
    }

    // MARK: - Combat

    private var combatSection: some View {
        Section("Combat") {
            statRow("Base attack bonus", Attack.signed(adventurer.baseAttackBonus))
            statRow("CMB", Attack.signed(adventurer.cmb))
            statRow("CMD", "\(adventurer.cmd)")
            statRow("Initiative", Attack.signed(adventurer.initiativeBonus))
            statRow("Speed", "\(adventurer.speed) ft")
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        LabeledContent(label) {
            Text(value).monospacedDigit()
        }
    }

    // MARK: - Attacks

    private var attacksSection: some View {
        Section("Attacks") {
            ForEach(adventurer.sortedAttacks) { attack in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(attack.name.isEmpty ? "Attack" : attack.name)
                        Text(attack.summaryLine)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Spacer()
                    Button("Roll") { roll(attack) }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                }
            }
        }
    }

    private func roll(_ attack: Attack) {
        let d20 = Dice.rawRoll(dieType: 20)
        rollResult = AttackRollResult(
            attackName: attack.name.isEmpty ? "Attack" : attack.name,
            d20: d20,
            toHit: attack.toHit,
            damage: attack.damage)
    }

    private var rollAlertBinding: Binding<Bool> {
        Binding(get: { rollResult != nil }, set: { if !$0 { rollResult = nil } })
    }

    // MARK: - Notes

    private var notesSection: some View {
        Section("Notes") {
            Text(adventurer.notes)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Supporting types

/// The result of rolling one attack's d20 to-hit, shown in an alert.
struct AttackRollResult: Identifiable {
    let id = UUID()
    let attackName: String
    let d20: Int
    let toHit: Int
    let damage: String

    var total: Int { d20 + toHit }

    var message: String {
        var text = "\(attackName)\nd20: \(d20)  \(Attack.signed(toHit))  =  \(total) to hit"
        let trimmedDamage = damage.trimmingCharacters(in: .whitespaces)
        if !trimmedDamage.isEmpty {
            text += "\nDamage: \(trimmedDamage)"
        }
        return text
    }
}

/// A reflowing grid of captioned stat cells (used for defenses and ability
/// scores). Uses an adaptive column layout so it collapses gracefully at large
/// Dynamic Type sizes rather than forcing a fixed three-across grid.
private struct StatGrid: View {
    struct Stat: Identifiable {
        let id = UUID()
        let caption: String
        let value: String
        var detail: String? = nil
    }

    let stats: [Stat]

    private let columns = [GridItem(.adaptive(minimum: 88), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(stats) { stat in
                VStack(spacing: 2) {
                    Text(stat.caption)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(stat.value)
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                    if let detail = stat.detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AdventurerView(selection: .preview)
    }
    .modelContainer(previewContainer)
}
#endif
