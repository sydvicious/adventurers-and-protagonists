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
    @Binding var isPresented: Bool
    @Binding var isReady: Bool
    @Binding var name: String
        
    @FocusState private var focus: NameEditorFocus?
    @State private var newName: String = ""

    var body: some View {
        VStack {
            Text("Enter your character's name")
                .multilineTextAlignment(.center)
            HStack{
#if os(iOS)
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
#else
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
#endif
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
        isPresented = false
    }

    func done() {
        name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        isPresented = false
    }

    func doneDisabled() -> Bool {
        return !isReady
    }

    private func updateIsReady() {
        isReady = !newName.isTrimmedStringEmpty()
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var isReady = false
    @Previewable @State var name = ""

    NameEditor(isPresented: $isPresented, isReady: $isReady, name: $name)
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var isReady = false
    @Previewable @State var name = "Pendecar"

    NameEditor(isPresented: $isPresented, isReady: $isReady, name: $name)
}
