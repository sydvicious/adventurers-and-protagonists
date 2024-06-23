//
//  AbilitiesViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 6/19/24.
//

import SwiftUI

protocol AbilitiesViewModelProtocol {

}

class AbilitiesViewModel: AbilitiesViewModelProtocol, ObservableObject {
    @Published @MainActor var abilities: [Ability] = []

    private var isNewCharacter: Bool = true

    init(abilities: [Ability] = []) {
        Task {@MainActor in
            self.abilities = abilities
        }
    }

    init(adventurer: Adventurer) {
        Task {@MainActor in
            self.abilities = adventurer.abilities
        }
    }

    init(proto: Proto) {
        Task {@MainActor in
            self.abilities = Proto.abilities(from: proto.abilities)
        }
    }

}
