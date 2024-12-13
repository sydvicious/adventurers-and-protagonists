//
//  AdventurerViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 6/20/24.
//

import SwiftUI

protocol AdventurerViewModelProtocol {

}

class AdventurerViewModel: AdventurerViewModelProtocol, ObservableObject {
    @Published @MainActor var selection: Adventurer = Adventurer(name: "", abilities: [])
    @Published @MainActor var isReady = true

    private var isNewCharacter = false

    @MainActor
    init(selection: Adventurer, isReady: Bool = true, isNewCharacter: Bool = false) {
        self.selection = selection
        self.isReady = isReady
        self.isNewCharacter = isNewCharacter
    }
}
