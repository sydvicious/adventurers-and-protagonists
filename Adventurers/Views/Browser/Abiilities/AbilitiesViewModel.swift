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

    @MainActor
    init(abilities: [Ability] = []) {
        self.abilities = abilities
    }

    @MainActor
    init(adventurer: Adventurer) {
        self.abilities = adventurer.abilities
    }

    @MainActor
    init(proto: Proto) {
        self.abilities = Proto.abilities(from: proto.abilities)
    }
}
