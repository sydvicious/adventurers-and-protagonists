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
    @State private var contentWidth: CGFloat = 0

    init(selection: Adventurer) {
        self.adventurer = selection
    }

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
        #if os(iOS)
        .navigationTitle(adventurer.name)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { editorShowing = true }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $editorShowing) {
            CharacterEditorView(editing: adventurer)
        }
    }

    // MARK: - Layout

    /// Switch to two columns once the detail is wide enough (iPad / Mac); iPhone stays
    /// single-column.
    private var isWide: Bool { contentWidth >= 700 }

    private var hasNotes: Bool {
        !adventurer.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private var narrowLayout: some View {
        VStack(spacing: 16) {
            headerSection
            hitPointsSection
            defensesSection
            abilitiesSection
            savesSection
            combatSection
            if hasNotes { notesSection }
        }
    }

    /// Header and the six-across ability grid span the full width; everything else flows
    /// into two columns.
    @ViewBuilder
    private var wideLayout: some View {
        VStack(spacing: 16) {
            headerSection
            abilitiesSection
            HStack(alignment: .top, spacing: 16) {
                VStack(spacing: 16) {
                    hitPointsSection
                    defensesSection
                    savesSection
                }
                VStack(spacing: 16) {
                    combatSection
                    if hasNotes { notesSection }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        GroupBox {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(adventurer.name)
                        .font(.title2.bold())
                    if !adventurer.headerSubtitle.isEmpty {
                        Text(adventurer.headerSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button {
                    editorShowing = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Hit points

    private var hitPointsSection: some View {
        HitPointsPanel(adventurer: adventurer)
    }

    // MARK: - Defenses

    private var defensesSection: some View {
        CollapsiblePanel("Defenses") {
            StatGrid(stats: [
                StatGrid.Stat(caption: "AC", value: "\(adventurer.armorClass)"),
                StatGrid.Stat(caption: "Touch", value: "\(adventurer.touchAC)"),
                StatGrid.Stat(caption: "Flat-footed", value: "\(adventurer.flatFootedAC)"),
            ])
        }
    }

    // MARK: - Ability scores

    private var abilitiesSection: some View {
        CollapsiblePanel("Ability Scores") {
            ColumnGrid(items: Ability.sortedByLabel(abilities: adventurer.abilities)) { ability in
                VStack(spacing: 2) {
                    Text(Self.abbreviation(for: ability.label))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(ability.score)")
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                    Text(Ability.modifierString(value: ability.score))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
        }
    }

    private static func abbreviation(for label: String) -> String {
        String(label.prefix(3)).uppercased()
    }

    // MARK: - Saving throws

    private var savesSection: some View {
        CollapsiblePanel("Saving Throws") {
            VStack(spacing: 8) {
                statRow("Fortitude", Attack.signed(adventurer.fortitude))
                statRow("Reflex", Attack.signed(adventurer.reflex))
                statRow("Will", Attack.signed(adventurer.will))
            }
        }
    }

    // MARK: - Combat

    private var combatSection: some View {
        CollapsiblePanel("Combat") {
            VStack(spacing: 8) {
                statRow("Base attack bonus", Attack.signed(adventurer.baseAttackBonus))
                statRow("CMB", Attack.signed(adventurer.cmb))
                statRow("CMD", "\(adventurer.cmd)")
                statRow("Initiative", Attack.signed(adventurer.initiativeBonus))
                statRow("Speed", "\(adventurer.speed) ft")
            }
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        LabeledContent(label) {
            Text(value).monospacedDigit()
        }
    }

    // MARK: - Notes

    private var notesSection: some View {
        CollapsiblePanel("Notes") {
            Text(adventurer.notes)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Supporting types

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
