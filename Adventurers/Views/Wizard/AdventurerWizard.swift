//
//  CreateAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

struct AdventurerWizard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var wizardShowing: Bool

    @State var proto = Proto()

    @State private var doneDisabled = true
    @State private var isReady = false

    // biography wizard
    @State private var biographyWizardShowing = false
    @State private var biographyReady = false

    // abilities wizard
    @State private var abilitiesWizardShowing = false
    @State private var abilitiesReady = false

    var selection: Adventurer?

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(proto.name.isTrimmedStringEmpty() ? "Unnamed" : "\(proto.name)")
                    Spacer()
                    HStack {
                        Button(action: {
                            biographyWizardShowing = true
                        }, label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .imageScale(.large)
                        })
                        ValidField(valid: $isReady)
                    }
                }
                if Proto.abilitiesReady(abilities: proto.abilities) {
                    let abilites = Proto.abilities(from: self.proto.abilities)
                    AbilitiesView(viewModel: AbilitiesViewModel(abilities: abilites))
                }
                Button(Proto.abilitiesReady(abilities: proto.abilities) ? "Edit Abilities" : "Setup Abilities", action: {
                    abilitiesWizardShowing = true
                })
            }
            .sheet(isPresented: $biographyWizardShowing, onDismiss: {
                biographyWizardShowing = false
                if proto.name.isTrimmedStringEmpty() {
                    wizardShowing = false
                }
                updateDoneButton()
            }, content: {
                NameEditor(proto: $proto, isReady: $isReady, isShowing: $biographyWizardShowing)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $abilitiesWizardShowing, onDismiss: {
                abilitiesWizardShowing = false
                updateDoneButton()
            }, content: {
                AbilitiesChooser(isShowing: $abilitiesWizardShowing,
                                 isReady: $abilitiesReady,
                                 proto: $proto,
                                 chooserType: Proto.abilitiesReady(abilities: proto.abilities) ? .transcribe : .intro)
            })
        }
        .onChange(of: abilitiesWizardShowing) {
            updateDoneButton()
        }
        .padding()
        Spacer()
        HStack {
            Button("Cancel", action: cancel)
            Button("Done", action: done)
                .disabled(doneDisabled)
        }
        .navigationTitle("Create a new adventurer")
        .onAppear {
            if proto.name.isEmpty {
                biographyWizardShowing = true
            }
            updateDoneButton()
        }
    }

    private func updateDoneButton() {
        isReady = proto.isReady(usePoints: false)
        doneDisabled = !isReady
    }

    private func cancel() {
        wizardShowing = false
    }

    private func done() {
        let adventurer = proto.adventurerFrom(usePoints: false)
        if let adventurer {
            withAnimation {
                modelContext.insert(adventurer)
            }
        }
        wizardShowing = false
    }
}

#Preview {
    @Previewable @State var wizardShowing = true

    AdventurerWizard(wizardShowing: $wizardShowing, selection: nil)
        .modelContainer(previewContainer)
}

#Preview {
    @Previewable @State var wizardShowing = false

    let proto = Proto()
    proto.name = "Pendecar"

    return AdventurerWizard(wizardShowing: $wizardShowing, proto: proto, selection: nil)
        .modelContainer(previewContainer)
}

#Preview {
    @Previewable @State var wizardShowing = false

    let proto = Proto()
    proto.name = "Pendecar"
    proto.abilities = Proto.baseAbilities()

    return AdventurerWizard(wizardShowing: $wizardShowing, proto: proto, selection: nil)
        .modelContainer(previewContainer)
}


