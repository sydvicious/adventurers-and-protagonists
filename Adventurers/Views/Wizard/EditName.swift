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
    @State private var doneDisabled: Bool = true

    @FocusState private var focus: NameFocus?

    var body: some View {
        VStack {
            Text("Choose a new name for your character")
                .multilineTextAlignment(.center)
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
                ValidField(valid: !newName.isTrimmedStringEmpty())
            }
            HStack {
                Button("Cancel", action: cancel)
                Button("Done", action: done)
                    .disabled(doneDisabled)
            }
        }
        .padding()
        .onAppear {
            newName = name
            updateDoneButton()
        }
    }

    private func updateDoneButton() {
        doneDisabled = newName.isTrimmedStringEmpty()
    }
    
    private func cancel() {
        name = ""
        nameWizardShowing = false
    }

    private func done() {
        name = newName
        nameWizardShowing = false
        newName = ""
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


