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
    @Binding var creatingNewCharacter: Bool // need to set this to false when returning.

    @State private var proto = Proto.dummyProtoData()

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
                AbilitiesView(viewModel: AbilitiesViewModel(proto: proto))
            }
            .sheet(isPresented: $biographyWizardShowing, onDismiss: {
                biographyWizardShowing = false
                if creatingNewCharacter && proto.name.isTrimmedStringEmpty() {
                    wizardShowing = false
                }
                updateDoneButton()
            }, content: {
                NameEditor(proto: $proto, isReady: $isReady, isNewCharacter: $creatingNewCharacter, isShowing: $biographyWizardShowing)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $abilitiesWizardShowing, onDismiss: {
                abilitiesWizardShowing = false
                updateDoneButton()
            }, content: {
                AbilitiesChooser(isShowing: $abilitiesWizardShowing, isReady: $abilitiesReady, proto: $proto, creatingNewCharacter: creatingNewCharacter)
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
        .navigationTitle(creatingNewCharacter ? "Create a new adventurer" : "Edit Character")
        .onAppear {
            if !creatingNewCharacter, let selection = selection {
                proto = Proto(from: selection)
            } else {
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
        creatingNewCharacter = false
    }

    private func done() {
        if creatingNewCharacter {
            let adventurer = proto.adventurerFrom(usePoints: false)
            if let adventurer {
                withAnimation {
                    modelContext.insert(adventurer)
                }
            }
            creatingNewCharacter = false
        } else {
            selection?.updateFromProto(proto)
        }
        wizardShowing = false
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var creatingNewCharacter = true

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: nil)
            .modelContainer(previewContainer)
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var creatingNewCharacter = false

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: SampleData.adventurers[0])
            .modelContainer(previewContainer)
    }
}

#Preview {
    @Previewable @State var wizardShowing = false
    @Previewable @State var creatingNewCharacter = false

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: SampleData.adventurers[0])
            .modelContainer(previewContainer)
    }
}
