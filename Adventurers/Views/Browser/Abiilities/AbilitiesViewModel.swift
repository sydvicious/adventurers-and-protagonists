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
    @Published @MainActor var isReady: Bool = false
    @Published @MainActor var abilities: [Ability] = []

    private var isNewCharacter: Bool = true

    init(isReady: Bool = false, isNewCharacter: Bool = true, abilities: [Ability] = []) {
        Task {@MainActor in
            self.isReady = isReady
            self.isNewCharacter = isNewCharacter
            self.abilities = abilities
        }
    }

}
