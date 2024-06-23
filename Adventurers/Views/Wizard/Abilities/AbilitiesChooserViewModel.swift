//
//  AbilitiesChooserViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//

import SwiftUI

enum AbilityChooserTypes: String, CaseIterable {
    case intro
    case transcribe
    case roll4d6Best3
    case points
    case test
}

class AbilitiesChooserViewModel: ObservableObject {

    @Published @MainActor var chooserType: AbilityChooserTypes = .intro
    @Published @MainActor var abilities: [ProtoAbility]
    @Published @MainActor var creatingNewCharacter: Bool

    @MainActor
    init(chooserType: AbilityChooserTypes = .intro,
         abilities: [ProtoAbility] = [],
         creatingNewCharacter: Bool) {
        self.chooserType = chooserType
        self.abilities = abilities
        self.creatingNewCharacter = creatingNewCharacter
    }
}
