//
//  AbilitiesChooser+Transcribe.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

@MainActor
extension AbilitiesChooser {
    @ViewBuilder func Transcribe() -> some View {
        AbilitiesView(viewModel: AbilitiesViewModel(proto: self.proto))
        .onAppear() {
            self.isReady = true
        }
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto()

    proto.abilities = Proto.baseAbilities()
    proto.name = "Pendecar"

    return AbilitiesChooser(isShowing: $wizardShowing, isReady: $isReady, proto: $proto, creatingNewCharacter: true, chooserType: .transcribe)
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto()

    proto.abilities = Proto.baseAbilities()
    proto.name = "Pendecar"

    return AbilitiesChooser(isShowing: $wizardShowing, isReady: $isReady, proto: $proto, creatingNewCharacter: false, chooserType: .transcribe)
}

