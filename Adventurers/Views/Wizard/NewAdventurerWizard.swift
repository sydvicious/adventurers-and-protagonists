//
//  NewAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 7/23/23.
//

import SwiftUI

enum WizardFocus: Hashable {
    case name
}

struct NewAdventurerWizard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var wizardShowing: Bool
    @Binding var selection: Adventurer?
    
    @State private var proto = Proto.dummyProtoData()
    
    @State private var doneDisabled = true
    @State private var nameValid = false
    
    @FocusState private var wizardFocus: WizardFocus?
        
    var body: some View {
        VStack {
            Text("New Advanturer Wizard")
            Spacer()
            Form {
                Section(header: Text("NAME")) {
                    HStack{
                        TextField("<NAME>", text: $proto.name)
                            .onChange(of: proto.name) {
                                updateDoneButton()
                            }
                            .onSubmit {
                                updateDoneButton()
                            }
                            .focused($wizardFocus, equals: .name)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    updateDoneButton()
                                    self.wizardFocus = .name
                                }
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .border(.secondary)
                        ValidField(valid: nameValid)
                    }
                }
                Section(header: Text("ABILITIES")) {
                    
                }
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

    private func setName() {

    }

    private func done() {
        let adventurer = proto.adventurerFrom(usePoints: false)
        if let adventurer {
            withAnimation {
                modelContext.insert(adventurer)
            }
            selection = adventurer
            wizardShowing = false
        } else {
            updateDoneButton()
        }
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

