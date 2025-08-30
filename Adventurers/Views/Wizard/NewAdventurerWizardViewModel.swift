//
//  NewAdventurerWizardViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 8/30/25.
//  Copyright ©2025 Syd Polk.
//

import SwiftUI

@MainActor
final class NewAdventurerWizardViewModel: ObservableObject {

    // Domain model under construction
    @Published var proto: Proto {
        didSet { recomputeIsReady() }
    }

    // Whether to validate abilities using point totals
    @Published var usePoints: Bool = false {
        didSet { recomputeIsReady() }
    }

    // Selected method for generating abilities
    @Published var abilitiesGeneratedMethod: AbilityGenerationMethod = .unspecified

    // Aggregate readiness used by the wizard's Done button
    @Published private(set) var isReady: Bool = false

    // Completion flag for the wizard
    @Published var isDone: Bool = false

    init(proto: Proto) {
        self.proto = proto
        recomputeIsReady()
    }

    // Call this when you mutate proto in a way that impacts readiness
    func notifyProtoChanged() {
        recomputeIsReady()
    }

    // MARK: - Aggregate readiness computation

    private func recomputeIsReady() {
        self.isReady = proto.isReady(usePoints: usePoints)
    }
}
