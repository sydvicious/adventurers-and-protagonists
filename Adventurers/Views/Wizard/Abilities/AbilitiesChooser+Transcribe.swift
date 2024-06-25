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
        let abilites = Proto.abilities(from: self.proto.abilities)
        AbilitiesView(viewModel: AbilitiesViewModel(abilities: abilites))
    }
}

#Preview {
    @Previewable @State var wizardShowing = true
    @Previewable @State var isReady = false
    @Previewable @State var proto = Proto()

    proto.abilities = Proto.baseAbilities()

    return AbilitiesChooser(isShowing: $wizardShowing, 
                            isReady: $isReady, 
                            proto: $proto,
                            chooserType: .transcribe)
}

