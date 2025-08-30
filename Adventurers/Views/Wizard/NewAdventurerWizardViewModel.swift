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

    // Required published properties
    @Published var proto: Proto
    @Published var isReady: Bool = false

    init(proto: Proto) {
        self.proto = proto
    }
}
