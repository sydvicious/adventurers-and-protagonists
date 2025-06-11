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
    @Published var abilities: [Ability] = []

    private var isNewCharacter: Bool = true

    init(abilities: [Ability] = []) {
        self.abilities = abilities
    }

    init(adventurer: Adventurer) {
        self.abilities = adventurer.abilities
    }

    init(proto: Proto) {
        self.abilities = Proto.abilities(from: proto.abilities)
    }
}
