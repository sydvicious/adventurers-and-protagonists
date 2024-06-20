//
//  AbilitiesTranscribeWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 1/28/24.
//

import SwiftUI

struct AbilitiesTranscribeWizard: View {
    @Binding var isReady: Bool
    @Binding var isNewCharacter: Bool
    @Binding var isShowing: Bool
    @Binding var abilities: [ProtoAbility]

    var body: some View {
        Grid {
            ForEach(abilities) {ability in
                AbilityGridRowView(name: ability.label, score: ability.score)
            }
        }
    }
}

#Preview {
    @Previewable @State var isReady = false
    @Previewable @State var isShowing = true
    @Previewable @State var isNewCharacter = true
    @Previewable @State var abilities: [ProtoAbility] = Proto.baseAbilities()

    return AbilitiesTranscribeWizard(isReady: $isReady, isNewCharacter: $isNewCharacter, isShowing: $isShowing, abilities: $abilities)
}
