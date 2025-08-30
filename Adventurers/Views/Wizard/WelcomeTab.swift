//
//  WelcomeTab.swift
//  Adventurers
//
//  Created by Syd Polk on 8/30/25.
//

import SwiftUI

struct WelcomeTab: View {
    @ObservedObject var viewModel: NewAdventurerWizardViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Pathfinder Adventurers")
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("This wizard will guide you through creating a new Pathfinder character.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview("Welcome Tab") {
    WelcomeTab(viewModel: NewAdventurerWizardViewModel(proto: Proto()))
}

