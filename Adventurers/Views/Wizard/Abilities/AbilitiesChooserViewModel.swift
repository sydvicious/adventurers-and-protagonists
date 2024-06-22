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

    var chooserType: AbilityChooserTypes = .intro
    var proto: Proto = Proto()

    @MainActor
    init(chooserType: AbilityChooserTypes = .intro,
         proto: Proto = Proto()) {
        self.chooserType = chooserType
        self.proto = proto
    }
}
