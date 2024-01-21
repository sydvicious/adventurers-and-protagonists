//
//  BiographyWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

struct BiographyWizard: WizardProtocol, View {
    @Environment(\.dismiss) var dismiss
    @Binding var proto: Proto
    @Binding var isReady: Bool
    @State var wizardShowing = false
    @State var newName = ""
    @State var detentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            Text("\(proto.name)")
                .bold()
        }
        .onAppear {
            self.wizardShowing = proto.name.isTrimmedStringEmpty()
            self.isReady = self.wizardShowing
        }
        .sheet(isPresented: $wizardShowing,
               onDismiss: nameWizardDismissed,
               content: {
            EditName(name: $newName, nameWizardShowing: $wizardShowing)
                .readHeight()
                .onPreferenceChange(HeightPreferenceKey.self) { height in
                    if let height {
                        self.detentHeight = height
                    }
                }
                .presentationDetents([.height(self.detentHeight)])
                .padding(.top)
        })
        .defaultScrollAnchor(.top)
    }

    private func nameWizardDismissed() {
        if proto.name.isEmpty || newName.isTrimmedStringEmpty() {
            dismiss()
        } else {
            proto = Proto.protoFromProto(oldProto: proto)
            proto.name = newName
            isReady = true
        }
    }

}


#Preview {
    @State var proto = Proto.dummyProtoData()
    @State var isReady = false

    return MainActor.assumeIsolated {
        BiographyWizard(proto: $proto, isReady: $isReady)
    }
}

#Preview {
    @State var proto = Proto.dummyProtoData()
    @State var isReady = true

    proto.name = "Pendecar"
    return MainActor.assumeIsolated {
        BiographyWizard(proto: $proto, isReady: $isReady)
    }
}
