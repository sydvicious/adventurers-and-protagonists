//
//  CharacterEditorView.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

/// The Phase-1 transcribe editor: a single grouped form for creating or editing
/// a basic-combatant character. Values are entered directly with minimal
/// validation — no rules engine. Used for both the "+" (create) and "Edit" paths.
struct CharacterEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var draft: CharacterDraft

    /// The adventurer being edited, or nil when creating a new one.
    private let editing: Adventurer?
    /// Called after a successful save with the saved adventurer's id, so the
    /// browser can select a freshly created character.
    private let onSaved: (PersistentIdentifier) -> Void

    init(editing: Adventurer? = nil,
         onSaved: @escaping (PersistentIdentifier) -> Void = { _ in }) {
        self.editing = editing
        self.onSaved = onSaved
        _draft = State(initialValue: CharacterDraft(from: editing))
    }

    var body: some View {
        NavigationStack {
            Form {
                identitySection
                abilitiesSection
                hitPointsSection
                defensesSection
                savesSection
                combatSection
                attacksSection
                notesSection

                Text("Transcribe flavor: values are entered directly, with minimal validation and no rules engine. The guided, rules-driven flavor comes later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
            .navigationTitle(draft.isNew ? "New Character" : "Edit Character")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!draft.canSave)
                }
            }
        }
    }

    // MARK: - Sections

    private var identitySection: some View {
        Section("Identity") {
            TextField("Name", text: $draft.name)
            TextField("Ancestry", text: $draft.ancestry)
            TextField("Class & level", text: $draft.classAndLevel)
            TextField("Alignment", text: $draft.alignment)
        }
    }

    private var abilitiesSection: some View {
        Section("Ability scores") {
            ForEach($draft.abilities) { $ability in
                IntFieldRow(label: ability.label, value: $ability.score, range: 1...60)
            }
        }
    }

    private var hitPointsSection: some View {
        Section("Hit points") {
            IntFieldRow(label: "Max HP", value: $draft.maxHP, range: 0...9999)
        }
    }

    private var defensesSection: some View {
        Section("Defenses") {
            IntFieldRow(label: "AC", value: $draft.armorClass, range: 0...99)
            IntFieldRow(label: "Touch", value: $draft.touchAC, range: 0...99)
            IntFieldRow(label: "Flat-footed", value: $draft.flatFootedAC, range: 0...99)
        }
    }

    private var savesSection: some View {
        Section("Saving throws") {
            IntFieldRow(label: "Fortitude", value: $draft.fortitude)
            IntFieldRow(label: "Reflex", value: $draft.reflex)
            IntFieldRow(label: "Will", value: $draft.will)
        }
    }

    private var combatSection: some View {
        Section("Combat") {
            IntFieldRow(label: "Base attack bonus", value: $draft.baseAttackBonus)
            IntFieldRow(label: "CMB", value: $draft.cmb)
            IntFieldRow(label: "CMD", value: $draft.cmd, range: 0...99)
            IntFieldRow(label: "Initiative", value: $draft.initiativeBonus)
            IntFieldRow(label: "Speed (ft)", value: $draft.speed, range: 0...999)
        }
    }

    private var attacksSection: some View {
        Section("Attacks") {
            ForEach($draft.attacks) { $attack in
                AttackEditorRow(attack: $attack)
            }
            .onDelete { offsets in
                draft.attacks.remove(atOffsets: offsets)
            }
            Button {
                draft.addAttack()
            } label: {
                Label("Add attack", systemImage: "plus.circle.fill")
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Notes", text: $draft.notes, axis: .vertical)
                .lineLimit(3...8)
        }
    }

    // MARK: - Save

    private func save() {
        let adventurer: Adventurer
        if let editing {
            adventurer = editing
        } else {
            adventurer = Adventurer(name: "", abilities: [])
            modelContext.insert(adventurer)
        }
        draft.apply(to: adventurer, in: modelContext)
        onSaved(adventurer.persistentModelID)
        dismiss()
    }
}

/// One editable attack line inside the editor.
private struct AttackEditorRow: View {
    @Binding var attack: AttackDraft

    var body: some View {
        VStack(spacing: 6) {
            TextField("Attack name", text: $attack.name)
                .font(.headline)
            IntFieldRow(label: "To hit", value: $attack.toHit)
            LabeledContent("Damage") {
                TextField("1d8+4", text: $attack.damage)
                    .multilineTextAlignment(.trailing)
            }
            IntFieldRow(label: "Crit ×", value: $attack.critMultiplier, range: 2...10)
            IntFieldRow(label: "Range (ft)", value: $attack.range, range: 0...999)
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview("New") {
    CharacterEditorView()
        .modelContainer(emptyContainer)
}

#Preview("Edit") {
    CharacterEditorView(editing: .preview)
        .modelContainer(previewContainer)
}
#endif
