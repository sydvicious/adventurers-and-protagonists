//
//  AdventurerView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

@MainActor
struct AdventurerView: View {
    @State private var selection: Adventurer
    @State private var creatingNewCharacter = false
    @State private var biographyWizardShowing =  false

    @ObservedObject var viewModel: AdventurerViewModel

    init(selection: Adventurer,
         creatingNewCharacter: Bool = false,
         biographyWizardShowing: Bool = false) {
        self.selection = selection
        self.creatingNewCharacter = creatingNewCharacter
        self.biographyWizardShowing = biographyWizardShowing
        self.viewModel = AdventurerViewModel(selection: selection)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text(selection.name)
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)

                AbilitiesView(viewModel: AbilitiesViewModel(adventurer: selection))
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            ToolbarItem {
                Button(action: edit) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
#if os(iOS)
        .fullScreenCover(isPresented: $biographyWizardShowing) {
            AdventurerWizard(wizardShowing: $biographyWizardShowing, 
                             selection: selection)
        }
#else
        .sheet(isPresented: $biographyWizardShowing) {
            AdventurerWizard(wizardShowing: $biographyWizardShowing,
                             selection: selection)
        }
#endif
    }

    func edit() {
        biographyWizardShowing = true
    }
}

#Preview {
    AdventurerView(selection: .preview)
        .modelContainer(previewContainer)
}
