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

struct NameEditor: View, WizardProtocol {
    @Binding var proto: Proto

    @Binding var isReady: Bool
    @Binding var isShowing: Bool

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
            newName = proto.name
            updateIsReady()
        }
        .padding()
    }

    func cancel() {
        isShowing = false
    }

    func done() {
        proto.name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
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
    @Previewable @State var isReady = false
    @Previewable @State var isShowing = true
    @Previewable @State var proto = Proto()
    proto.name = ""

    return NameEditor(proto: $proto, isReady: $isReady, isShowing: $isShowing)
}

#Preview {
    @Previewable @State var isReady = true
    @Previewable @State var isShowing = false
    @Previewable @State var proto = Proto()
    proto.name = "Pendecar"

    return NameEditor(proto: $proto, isReady: $isReady, isShowing: $isShowing)
}
