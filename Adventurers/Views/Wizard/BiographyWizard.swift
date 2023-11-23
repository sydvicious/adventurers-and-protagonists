//
//  BiographyWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

struct BiographyWizard: View {
    @Environment(\.dismiss) var dismiss
    @Binding var proto: Proto
    @State var nameWizardShowing = false
    @State var newName = ""

    var body: some View {
        ScrollView {
            Text("\(proto.name)")
                .bold()
        }
        .onAppear {
            self.nameWizardShowing = proto.name.isTrimmedStringEmpty()
        }
        .sheet(isPresented: $nameWizardShowing,
               onDismiss: nameWizardDismissed,
               content: {
            EditName(name: $newName, nameWizardShowing: $nameWizardShowing)
        })
    }

    private func nameWizardDismissed() {
        if proto.name.isEmpty && newName.isTrimmedStringEmpty() {
            dismiss()
        } else {
            proto = Proto.protoFromProto(oldProto: proto)
            proto.name = newName
        }
    }

}


#Preview {
    @State var proto = Proto.dummyProtoData()
    return MainActor.assumeIsolated {
        BiographyWizard(proto: $proto)
    }
}

#Preview {
    @State var proto = Proto.dummyProtoData()
    proto.name = "Pendecar"
    return MainActor.assumeIsolated {
        BiographyWizard(proto: $proto)
    }
}
