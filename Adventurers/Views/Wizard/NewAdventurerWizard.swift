//
//  NewAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 8/30/25.
//  Copyright ©2025 Syd Polk.
//

import SwiftUI

struct NewAdventurerWizard: View {
    private let viewModel = NewAdventurerWizardViewModel(proto: Proto())

    var body: some View {
        TabView {
            BiographyTab(viewModel: viewModel)
            AbilitiesTab(viewModel: viewModel)
            RaceTab(viewModel: viewModel)
            ClassTab(viewModel: viewModel)
            FeatsTab(viewModel: viewModel)
            SkillsTab(viewModel: viewModel)
            EquipmentTab(viewModel: viewModel)
            CombatTab(viewModel: viewModel)
            SpellsTab(viewModel: viewModel)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// MARK: - Previews

#Preview("New Adventurer Wizard") {
    NavigationStack {
        NewAdventurerWizard()
    }
}
