//
//  AbilitiesView.swift
//  Adventurers
//
//  Created by Syd Polk on 1/28/24.
//

import SwiftUI

struct AbilitiesView: View {
    @ObservedObject var viewModel: AbilitiesViewModel

    var body: some View {
        Grid {
            if (viewModel.abilities.count == 0) {
                Text("No abilities! Is this thing on?")
            } else {
                ForEach(viewModel.abilities) {ability in
                    AbilityGridRowView(name: ability.label, score: ability.score)
                }
            }
        }
    }
}

#Preview("Existing Abilities") {
    var debuggingText = "abilties accumulater: "
    var stagingAbilities: [Ability] = []
    let protoAbilities = Proto.baseAbilities()

    protoAbilities.forEach{protoAbility in
        debuggingText += "\(protoAbility.label): - \(protoAbility.score) "
        stagingAbilities.append(protoAbility.ability())
    }
    let viewModel = AbilitiesViewModel(abilities: stagingAbilities)
    return AbilitiesView(viewModel: viewModel)
}

#Preview("From Scratch") {
    let viewModel = AbilitiesViewModel(abilities: [])
    AbilitiesView(viewModel: viewModel)
}

