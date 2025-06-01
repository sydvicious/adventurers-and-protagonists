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
}

class AbilitiesChooserViewModel: ObservableObject {

    @Published @MainActor var chooserType: AbilityChooserTypes = .intro
    @Published @MainActor var abilities: [ProtoAbility]
    @Published @MainActor var doneDisabled: Bool = true

    @MainActor
    init(chooserType: AbilityChooserTypes,
         abilities: [ProtoAbility] = []) {
        self.chooserType = chooserType
        self.abilities = abilities
    }

    @MainActor
    init(abilities: [ProtoAbility] = []) {
        self.chooserType = .intro
        self.abilities = abilities
    }

    @MainActor
    func checkDoneDisabled() {
        self.doneDisabled = !Proto.abilitiesReady(abilities: self.abilities)
    }
}
