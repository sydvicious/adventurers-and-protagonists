//
//  NameEditor.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

enum NameEditorFocus: Hashable {
    case name
}

struct NameEditor: View {
    @Binding var isReady: Bool
    @Binding var isNewCharacter: Bool
    @Binding var isShowing: Bool
    @Binding var name: String

    @FocusState private var focus: NameEditorFocus?
    @State var newName: String = ""

    var body: some View {
        VStack {
            Text("Enter your character's name")
                .multilineTextAlignment(.center)
            HStack{
                TextField("<NAME>", text: $newName)
                    .onChange(of: newName) {
                        updateIsReady()
                    }
                    .onSubmit {
                        updateIsReady()
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
                ValidField(valid: $isReady)
            }
            Spacer()
            HStack {
                Button("Cancel", action: cancel)
                Button("Done", action: done)
                    .disabled(doneDisabled())
            }
        }
        .onAppear {
            newName = name
            updateIsReady()
        }
        .padding()
    }

    func cancel() {
        isShowing = false
    }

    func done() {
        name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        isShowing = false
    }

    func doneDisabled() -> Bool {
        return !isReady
    }

    private func updateIsReady() {
        isReady = !newName.isTrimmedStringEmpty()
    }
}

#Preview {
    @State var isReady = false
    @State var isShowing = true
    @State var isNewCharacter = true
    @State var newName = ""

    return NameEditor(isReady: $isReady, isNewCharacter: $isNewCharacter, isShowing: $isShowing, name: $newName)
}

#Preview {
    @State var isReady = true
    @State var isShowing = false
    @State var isNewCharacter = false
    @State var newName = "Pendecar"

    return NameEditor(isReady: $isReady, isNewCharacter: $isNewCharacter, isShowing: $isShowing, name: $newName)
}
