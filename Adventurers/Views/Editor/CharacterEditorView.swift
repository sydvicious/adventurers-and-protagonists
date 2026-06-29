//
//  CharacterEditorView.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

/// The Phase-1 transcribe editor: enter a basic-combatant character's values directly,
/// with minimal validation and no rules engine. Used for both the "+" (create) and
/// "Edit" paths. iOS uses a single-column grouped `Form`; macOS uses a scrollable
/// two-column layout with an explicit Cancel/Save bar (Cancel is also bound to Esc).
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

    private var title: String { draft.isNew ? "New Character" : "Edit Character" }

    private let footnote = "Transcribe flavor: values are entered directly, with minimal validation and no rules engine. The guided, rules-driven flavor comes later."

    var body: some View {
        #if os(macOS)
        macBody
        #else
        iosBody
        #endif
    }

    // MARK: - iOS

    #if !os(macOS)
    private var iosBody: some View {
        NavigationStack {
            Form {
                Section("Identity") { identityFields }
                Section("Ability scores") { abilityFields }
                Section("Hit points") { hitPointsFields }
                Section("Defenses") { defenseFields }
                Section("Saving throws") { saveFields }
                Section("Combat") { combatFields }
                Section("Attacks") {
                    ForEach($draft.attacks) { $attack in
                        AttackEditorRow(attack: $attack)
                    }
                    .onDelete { draft.attacks.remove(atOffsets: $0) }
                    addAttackButton
                }
                Section("Notes") { notesField }

                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!draft.canSave)
                }
            }
        }
    }
    #endif

    // MARK: - macOS

    #if os(macOS)
    private var macBody: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).font(.title3.bold())
                Spacer()
            }
            .padding()

            Divider()

            ScrollView {
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 16) {
                        macGroup("Identity") { identityFields }
                        macGroup("Ability scores") { abilityFields }
                        macGroup("Notes") { notesField }
                    }
                    VStack(spacing: 16) {
                        macGroup("Hit points") { hitPointsFields }
                        macGroup("Defenses") { defenseFields }
                        macGroup("Saving throws") { saveFields }
                        macGroup("Combat") { combatFields }
                        macGroup("Attacks") { macAttacksContent }
                    }
                }
                .padding()

                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal, .bottom])
            }

            Divider()

            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Save", action: save)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!draft.canSave)
            }
            .padding()
        }
        .frame(minWidth: 700, idealWidth: 840, minHeight: 520, idealHeight: 680)
    }

    private func macGroup<Content: View>(_ title: String,
                                         @ViewBuilder _ content: () -> Content) -> some View {
        GroupBox(title) {
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
        }
    }

    @ViewBuilder
    private var macAttacksContent: some View {
        ForEach($draft.attacks) { $attack in
            VStack(spacing: 6) {
                AttackEditorRow(attack: $attack)
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        draft.attacks.removeAll { $0.id == attack.id }
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }
            Divider()
        }
        addAttackButton
    }
    #endif

    // MARK: - Shared field builders (no Section/GroupBox wrapper)

    @ViewBuilder
    private var identityFields: some View {
        TextField("Name", text: $draft.name)
        TextField("Ancestry", text: $draft.ancestry)
        TextField("Class & level", text: $draft.classAndLevel)
        TextField("Alignment", text: $draft.alignment)
    }

    @ViewBuilder
    private var abilityFields: some View {
        ForEach($draft.abilities) { $ability in
            IntFieldRow(label: ability.label, value: $ability.score, range: 1...60)
        }
    }

    @ViewBuilder
    private var hitPointsFields: some View {
        IntFieldRow(label: "Max HP", value: $draft.maxHP, range: 0...9999)
    }

    @ViewBuilder
    private var defenseFields: some View {
        IntFieldRow(label: "AC", value: $draft.armorClass, range: 0...99)
        IntFieldRow(label: "Touch", value: $draft.touchAC, range: 0...99)
        IntFieldRow(label: "Flat-footed", value: $draft.flatFootedAC, range: 0...99)
    }

    @ViewBuilder
    private var saveFields: some View {
        IntFieldRow(label: "Fortitude", value: $draft.fortitude)
        IntFieldRow(label: "Reflex", value: $draft.reflex)
        IntFieldRow(label: "Will", value: $draft.will)
    }

    @ViewBuilder
    private var combatFields: some View {
        IntFieldRow(label: "Base attack bonus", value: $draft.baseAttackBonus)
        IntFieldRow(label: "CMB", value: $draft.cmb)
        IntFieldRow(label: "CMD", value: $draft.cmd, range: 0...99)
        IntFieldRow(label: "Initiative", value: $draft.initiativeBonus)
        IntFieldRow(label: "Speed (ft)", value: $draft.speed, range: 0...999)
    }

    @ViewBuilder
    private var notesField: some View {
        TextField("Notes", text: $draft.notes, axis: .vertical)
            .lineLimit(3...8)
    }

    private var addAttackButton: some View {
        Button {
            draft.addAttack()
        } label: {
            Label("Add attack", systemImage: "plus.circle.fill")
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
            IntFieldRow(label: "Crit threat (nat ≥)", value: $attack.threatRange, range: 2...20)
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
