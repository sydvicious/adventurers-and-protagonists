//
//  NewAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 8/30/25.
//  Copyright ©2025 Syd Polk.
//

import SwiftUI

struct NewAdventurerWizard: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NewAdventurerWizardViewModel(proto: Proto())

    // Track the current page in the TabView
    @State private var selection: Int = 0
    private let lastIndex: Int = 9 // 10 tabs: indices 0...9

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left navigation arrow
            Button {
                withAnimation {
                    selection = max(0, selection - 1)
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.largeTitle)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(selection == 0 ? .secondary : .primary)
                    .accessibilityLabel("Previous")
            }
            .disabled(selection == 0)

            // The paged TabView
            TabView(selection: $selection) {
                WelcomeTab(viewModel: viewModel)
                    .tag(0)
                BiographyTab(viewModel: viewModel)
                    .tag(1)
                AbilitiesTab(viewModel: viewModel)
                    .tag(2)
                RaceTab(viewModel: viewModel)
                    .tag(3)
                ClassTab(viewModel: viewModel)
                    .tag(4)
                FeatsTab(viewModel: viewModel)
                    .tag(5)
                SkillsTab(viewModel: viewModel)
                    .tag(6)
                EquipmentTab(viewModel: viewModel)
                    .tag(7)
                CombatTab(viewModel: viewModel)
                    .tag(8)
                SpellsTab(viewModel: viewModel)
                    .tag(9)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Right navigation arrow
            Button {
                withAnimation {
                    selection = min(lastIndex, selection + 1)
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.largeTitle)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(selection == lastIndex ? .secondary : .primary)
                    .accessibilityLabel("Next")
            }
            .disabled(selection == lastIndex)
        }
        .padding(.horizontal)
        // Bottom action bar
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                Button("Done") {
                    viewModel.isDone = true
                    dismiss()
                }
                .disabled(!viewModel.isReady)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Previews

#Preview("New Adventurer Wizard") {
    NavigationStack {
        NewAdventurerWizard()
    }
}
