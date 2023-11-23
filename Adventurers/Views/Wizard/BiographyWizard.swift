//
//  BiographyWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

struct BiographyWizard: View {
    @Binding var proto: Proto
    @Binding var nameValid: Bool

    var body: some View {
        viewPicker()
    }

    @ViewBuilder
    private func viewPicker() -> some View {
        if !nameValid {
            Button("Edit Name", action: {

            })
        } else {
            Text(proto.name)
        }
    }

    static func validateName(proto: Proto) -> Bool {
        let trimmedName = proto.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedName != ""
    }

}



#Preview {
    @State var proto = Proto.dummyProtoData()
    @State var nameValid = BiographyWizard.validateName(proto: proto)
    return MainActor.assumeIsolated {
        BiographyWizard(proto: $proto,
                        nameValid: $nameValid)
    }
}

