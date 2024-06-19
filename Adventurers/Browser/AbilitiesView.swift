//
//  AbilitiesView.swift
//  Adventurers
//
//  Created by Syd Polk on 1/28/24.
//

import SwiftUI

struct AbilitiesView: View {
    @Binding var isReady: Bool
    @Binding var isNewCharacter: Bool
    @Binding var abilities: [Ability]

    var body: some View {
        Grid {
            if (abilities.count == 0) {
                Text("No abilities! Is this thing on?")
            } else {
                ForEach(abilities) {ability in
                    AbilityGridRowView(name: ability.label, score: ability.score)
                }
            }
        }
    }
}

#Preview {
    @State var isReady = false
    @State var isNewCharacter = true

    let protoAbilities = Proto.baseAbilities()
    if protoAbilities.count == 0 {
        return Text("No proto abilities!")
    } else {
        var debuggingText = "abilties accumulater: "
        var stagingAbilities: [Ability] = []
        protoAbilities.forEach{protoAbility in
            debuggingText += "\(protoAbility.label): - \(protoAbility.score) "
            stagingAbilities.append(Ability(label: protoAbility.label, score: protoAbility.score))
        }
        if stagingAbilities.count == 0 {
            return Text("no calculated abilities, protoAbilities.count = \(protoAbilities.count) \(debuggingText)")
        }
        @State var abilities : [Ability] = stagingAbilities
        return AbilitiesView(isReady: $isReady, isNewCharacter: $isNewCharacter, abilities: $abilities)
    }
}
