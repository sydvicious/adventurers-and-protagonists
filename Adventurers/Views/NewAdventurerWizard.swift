//
//  NewAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 7/23/23.
//

import SwiftUI

struct NewAdventurerWizard: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var wizardShowing: Bool
    @Binding var selection: Adventurer?
    
    @State private var proto = Proto.dummyProtoData()
    
    @State private var doneDisabled = true
    @State private var nameValid = false
    
    var body: some View {
        VStack {
            Text("New Character Wizard")
            Spacer()
            Form {
                Grid {
                    GridRow {
                        Text("Please provide a name for your new character:")
                        Spacer()
                        if nameValid {
                            Text("✔️")
                                .background(.red)
                        }
                    }
                }
                TextField("<NAME>", text: $proto.name)
                    .onSubmit {
                        updateDoneButton()
                    }
                    .onAppear {
                        updateDoneButton()
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
            }
            HStack {
                Button("Cancel", action: cancel)
                Button("Done", action: done)
                    .disabled(doneDisabled)
            }
        }
    }
        
    private func validateName() {
        let trimmedName = proto.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        nameValid = trimmedName != ""
    }

    private func updateDoneButton() {
        validateName()
        doneDisabled = !(nameValid)
    }
    
    private func cancel() {
        wizardShowing = false
    }
    
    private func done() {
        wizardShowing = false
        
        let adventurer = proto.adventurerFrom()
        if let adventurer {
            withAnimation {
                modelContext.insert(adventurer)
            }
        }
        selection = adventurer
    }
}

#Preview {
    @State var wizardShowing = true
    @State var selection: Adventurer? = nil
    
    return MainActor.assumeIsolated {
        NewAdventurerWizard(wizardShowing: $wizardShowing, selection: $selection)
            .modelContainer(previewContainer)
    }
}

