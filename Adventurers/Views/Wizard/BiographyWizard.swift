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
}


#Preview {
    @State var proto = Proto.dummyProtoData()
    @State var nameValid = proto.name.isTrimmedStringEmpty()
    return MainActor.assumeIsolated {
        BiographyWizard(proto: $proto,
                        nameValid: $nameValid)
    }
}

#Preview {
    @State var proto = Proto.dummyProtoData()
    proto.name = "Pendecar"
    @State var nameValid = proto.name.isTrimmedStringEmpty()
    return MainActor.assumeIsolated {
        BiographyWizard(proto: $proto,
                        nameValid: $nameValid)
    }
}
