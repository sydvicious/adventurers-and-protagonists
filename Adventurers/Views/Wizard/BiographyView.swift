//
//  WizardStepRowView.swift
//  Adventurers
//
//  Created by Syd Polk on 1/14/24.
//

import SwiftUI

struct BiographyView<Content: View>: View {
    @ViewBuilder var stepEditor: Content

    @Binding var proto: Proto
    @Binding var stepReady: Bool

    var stepName: String
    @State var presentView: Bool = false

    var body: some View {
        HStack {
            BiographyWizard(proto: $proto, isReady: $stepReady)
            Spacer()
            Button("Edit") {
                presentView = true
            }
            ValidField(valid: stepReady)
        }
        .padding(10)
        .fullScreenCover(isPresented: $presentView, content: {
            stepEditor
        })
    }
}

#Preview {
    @State var proto: Proto = Proto.dummyProtoData()
    @State var stepReady: Bool = false

    return BiographyView(stepEditor: {BiographyWizard(proto: $proto, isReady: $stepReady)},
                     proto: $proto,
                     stepReady: $stepReady,
                     stepName: "Biography")
}

#Preview {
    @State var proto: Proto = Proto.dummyProtoData()
    proto.name = "Pendecar"
    @State var stepReady: Bool = true

    return BiographyView(stepEditor: {BiographyWizard(proto: $proto, isReady: $stepReady)},
                     proto: $proto,
                     stepReady: $stepReady,
                     stepName: "Biography")
}
