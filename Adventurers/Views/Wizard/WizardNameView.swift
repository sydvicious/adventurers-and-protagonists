//
//  WizardNameView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/23/23.
//

import SwiftUI

struct WizardNameView: View {
    @Binding var proto: Proto
    @Binding var sectionsComplete: [WizardSectionNames:Bool]

    var body: some View {
        TextField("<NAME>", text: $proto.name)
            .onAppear {
                validateName()
            }
            .onSubmit {
                validateName()
            }
            .onChange(of: proto.name) {
                validateName()
            }
    }

    private func validateName() {
        let trimmedName = proto.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        sectionsComplete[.name] = trimmedName != ""
    }

}

#Preview {
    @State var proto = Proto()
    @State var sectionsComplete: [WizardSectionNames:Bool] = [
        .name: false
    ]
    return WizardNameView(proto: $proto, sectionsComplete: $sectionsComplete)
}
