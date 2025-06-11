//
//  AdventurerView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

struct AdventurerView: View {
    @ObservedObject var viewModel: AdventurerViewModel

    init(selection: Adventurer) {
        self.viewModel = AdventurerViewModel(selection: selection)
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                AbilitiesView(viewModel: AbilitiesViewModel(adventurer: viewModel.selection))
                .padding()
                .frame(maxWidth: .infinity)
                .navigationTitle(viewModel.selection.name)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            }
            .toolbar {
                ToolbarItem {
                    Button(action: edit) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
#if os(iOS)
            .fullScreenCover(isPresented: $viewModel.wizardShowing) {
                presentWizard()
            }
#else
            .sheet(isPresented: $viewModel.wizardShowing) {
                presentWizard()
            }
#endif
        }
    }

    func edit() {
        viewModel.wizardShowing = true
    }
    
    @ViewBuilder
    func presentWizard() -> some View {
        let wizardViewModel = WizardViewModel(proto: Proto(from: viewModel.selection))
        AdventurerWizard(wizardShowing: $viewModel.wizardShowing)
            .environmentObject(wizardViewModel)
    }
}

#Preview {
    AdventurerView(selection: .preview)
        .modelContainer(previewContainer)
}
