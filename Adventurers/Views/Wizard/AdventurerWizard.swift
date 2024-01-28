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
    @State private var newName = ""

    var selection: Adventurer?

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(proto.name.isTrimmedStringEmpty() ? "Unnamed" : "\(newName)")
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
            }
            .sheet(isPresented: $biographyWizardShowing, onDismiss: {
                biographyWizardShowing = false
                if creatingNewCharacter && newName.isTrimmedStringEmpty() {
                    wizardShowing = false
                }
            }, content: {
                NameEditor(isReady: $isReady, isNewCharacter: $creatingNewCharacter, isShowing: $biographyWizardShowing, name: $newName)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            })
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
                newName = proto.name
            } else {
                biographyWizardShowing = true
            }
            updateDoneButton()
        }
        .onChange(of: newName) {
            proto.name = newName
            updateDoneButton()
        }
    }

    private func updateDoneButton() {
        doneDisabled = newName.isTrimmedStringEmpty()
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
    @State var wizardShowing = true
    @State var creatingNewCharacter = true

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: nil)
            .modelContainer(previewContainer)
    }
}

#Preview {
    @State var wizardShowing = true
    @State var creatingNewCharacter = false

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: SampleData.adventurers[0])
            .modelContainer(previewContainer)
    }
}

#Preview {
    @State var wizardShowing = false
    @State var creatingNewCharacter = false

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: SampleData.adventurers[0])
            .modelContainer(previewContainer)
    }
}
