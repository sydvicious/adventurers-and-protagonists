//
//  AdventurerViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 6/20/24.
//

import SwiftUI

class AdventurerViewModel: ObservableObject {
    @Published var selection: Adventurer = Adventurer(name: "", abilities: [])
    @Published var wizardShowing =  false

    init(selection: Adventurer, isReady: Bool = true) {
        self.selection = selection
    }
}

