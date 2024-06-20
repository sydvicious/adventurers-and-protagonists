//
//  AbilitiesTranscribeWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 1/28/24.
//

import SwiftUI

struct AbilitiesTranscribeWizard: View, WizardProtocol {
    @Binding var proto: Proto

    @Binding var isReady: Bool
    @Binding var isNewCharacter: Bool
    @Binding var isShowing: Bool

    var body: some View {
        Grid {
            ForEach(proto.abilities) {ability in
                AbilityGridRowView(name: ability.label, score: ability.score)
            }
        }
        .onAppear() {
            isReady = true
        }
    }
}

#Preview {
    @Previewable @State var isReady = false
    @Previewable @State var isShowing = true
    @Previewable @State var isNewCharacter = true
    @Previewable @State var proto = Proto()
    proto.abilities = Proto.baseAbilities()

    return AbilitiesTranscribeWizard(proto: $proto, isReady: $isReady, isNewCharacter: $isNewCharacter, isShowing: $isShowing)
}
