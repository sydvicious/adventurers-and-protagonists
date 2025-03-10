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

    @EnvironmentObject var viewModel: WizardViewModel

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(viewModel.proto.name.isTrimmedStringEmpty() ? "Unnamed" : "\(viewModel.proto.name)")
                    Spacer()
                    HStack {
                        Button(action: {
                            viewModel.biographyWizardShowing = true
                        }, label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .imageScale(.large)
                        })
                        ValidField(valid: $viewModel.isReady)
                    }
                }
                if Proto.abilitiesReady(abilities: viewModel.proto.abilities) {
                    let abilites = Proto.abilities(from: self.viewModel.proto.abilities)
                    AbilitiesView(viewModel: AbilitiesViewModel(abilities: abilites))
                }
                Button(Proto.abilitiesReady(abilities: viewModel.proto.abilities) ? "Edit Abilities" : "Setup Abilities", action: {
                    viewModel.abilitiesWizardShowing = true
                })
            }
            .sheet(isPresented: $viewModel.biographyWizardShowing, onDismiss: {
                viewModel.biographyWizardShowing = false
                if viewModel.proto.name.isTrimmedStringEmpty() {
                    wizardShowing = false
                }
                updateDoneButton()
            }, content: {
                NameEditor(isPresented: $viewModel.biographyWizardShowing,
                           isReady: $viewModel.biographyReady,
                           name: $viewModel.proto.name)
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $viewModel.abilitiesWizardShowing, onDismiss: {
                viewModel.abilitiesWizardShowing = false
                updateDoneButton()
            }, content: {
                AbilitiesChooser(isShowing: $viewModel.abilitiesWizardShowing,
                                 isReady: $viewModel.abilitiesReady,
                                 proto: $viewModel.proto,
                                 chooserType: Proto.abilitiesReady(abilities: viewModel.proto.abilities) ? .transcribe : .intro)
            })
        }
        .onChange(of: viewModel.abilitiesWizardShowing) {
            updateDoneButton()
        }
        .padding()
        Spacer()
        HStack {
            Button("Cancel", action: cancel)
            Button("Done", action: done)
                .disabled(viewModel.doneDisabled)
        }
        .navigationTitle("Create a new adventurer")
        .onAppear {
            if viewModel.proto.name.isEmpty {
                viewModel.biographyWizardShowing = true
            }
            updateDoneButton()
        }
    }

    private func updateDoneButton() {
        viewModel.isReady = viewModel.proto.isReady(usePoints: false)
        viewModel.doneDisabled = !viewModel.isReady
    }

    private func cancel() {
        wizardShowing = false
    }

    private func done() {
        let adventurer = viewModel.proto.adventurerFrom(usePoints: false)
        if let adventurer {
            withAnimation {
                modelContext.insert(adventurer)
                Task {
                    do {
                        try modelContext.save()
                    } catch {
                        fatalError("Could not save modelContext: \(error)")
                    }
                }
            }
        }
        wizardShowing = false
    }
}

#Preview {
    @Previewable @State var wizardShowing = true

    AdventurerWizard(wizardShowing: $wizardShowing)
        .modelContainer(previewContainer)
}

#Preview {
    @Previewable @State var wizardShowing = false
    
    let proto = Proto()
    proto.name = "Pendecar"
    let viewModel = WizardViewModel(proto: proto)

    return AdventurerWizard(wizardShowing: $wizardShowing)
        .environmentObject(viewModel)
        .modelContainer(previewContainer)
}

#Preview {
    @Previewable @State var wizardShowing = false

    let proto = Proto()
    proto.name = "Pendecar"
    proto.abilities = Proto.baseAbilities()
    let viewModel = WizardViewModel(proto: proto)

    return AdventurerWizard(wizardShowing: $wizardShowing)
        .environmentObject(viewModel)
        .modelContainer(previewContainer)
}


