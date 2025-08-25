//
//  AbilitiesChooserViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 6/22/24.
//  Copyright ©2024 Syd Polk. All rights reserved.
//

import SwiftUI

enum AbilityChooserTypes: String, CaseIterable {
    case intro
    case transcribe
    case roll4d6Best3
    case points
}

class AbilitiesChooserViewModel: ObservableObject {

    @Published var chooserType: AbilityChooserTypes = .intro
    @Published var abilities: [ProtoAbility]

    init(chooserType: AbilityChooserTypes,
         abilities: [ProtoAbility] = []) {
        self.chooserType = chooserType
        self.abilities = abilities
    }

    init(abilities: [ProtoAbility] = []) {
        self.chooserType = .intro
        self.abilities = abilities
    }

}
