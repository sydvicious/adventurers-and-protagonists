//
//  WizardViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 3/10/25.
//

import SwiftUI

class WizardViewModel: ObservableObject {

    @MainActor @Published var proto: Proto
    @MainActor @Published var isReady = false
    
    @MainActor @Published var doneDisabled = true

    // biography wizard
    @MainActor @Published var biographyWizardShowing = false
    @MainActor @Published var biographyReady = false

    // abilities wizard
    @MainActor @Published var abilitiesWizardShowing = false
    @MainActor @Published var abilitiesReady = false
    
    @MainActor
    init(proto: Proto) {
        self.proto = proto
    }
}
