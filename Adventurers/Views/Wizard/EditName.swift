//
//  EditName.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

enum NameFocus: Hashable {
    case name
}

struct EditName: View {
    @Binding var name: String
    @Binding var nameWizardShowing: Bool

    @State var newName: String = ""
    @State var nameValid: Bool = false
    @State private var doneDisabled: Bool = true

    @FocusState private var focus: NameFocus?

    var body: some View {
        VStack {
            HStack{
                TextField("<NAME>", text: $newName)
                    .onChange(of: newName) {
                        updateDoneButton()
                    }
                    .onSubmit {
                        updateDoneButton()
                    }
                    .focused($focus, equals: .name)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            newName = name
                            updateDoneButton()
                            self.focus = .name
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
            HStack {
                Button("Cancel", action: cancel)
                Button("Done", action: done)
                    .disabled(doneDisabled)
            }
        }
    }

    private func updateDoneButton() {
        validateName()
        doneDisabled = !(nameValid)
    }

    private func validateName() {
        nameValid = newName.isTrimmedStringEmpty()
    }

    private func cancel() {
        nameWizardShowing = false
    }

    private func done() {
        name = newName
        nameWizardShowing = false
    }
}

#Preview {
    @State var name: String = ""
    @State var nameWizardShowing = true
    
    return EditName(name: $name, nameWizardShowing: $nameWizardShowing)
}

#Preview {
    @State var name: String = "Pendecar"
    @State var nameWizardShowing = true

    return EditName(name: $name, nameWizardShowing: $nameWizardShowing)
}


