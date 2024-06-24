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

#if DEBUG
    @MainActor
    init(chooserType: AbilityChooserTypes,
         abilities: [ProtoAbility] = [],
         creatingNewCharacter: Bool) {
        self.chooserType = chooserType
        self.abilities = abilities
        self.creatingNewCharacter = creatingNewCharacter
    }
#endif

    @MainActor
    init(abilities: [ProtoAbility] = [],
         creatingNewCharacter: Bool) {
        self.chooserType = creatingNewCharacter ? .intro : .transcribe
        self.abilities = abilities
        self.creatingNewCharacter = creatingNewCharacter
    }

}
