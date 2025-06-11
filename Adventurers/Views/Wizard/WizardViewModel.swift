//
//  WizardViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 3/10/25.
//

import SwiftUI

class WizardViewModel: ObservableObject {

    @Published var proto: Proto
    @Published var isReady = false
    
    @Published var doneDisabled = true

    // biography wizard
    @Published var biographyWizardShowing = false
    @Published var biographyReady = false

    // abilities wizard
    @Published var abilitiesWizardShowing = false
    @Published var abilitiesReady = false
    
    @MainActor
    init(proto: Proto) {
        self.proto = proto
    }
}
