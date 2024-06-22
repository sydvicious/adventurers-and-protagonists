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
                    .border(.black)

                AbilitiesView(viewModel: AbilitiesViewModel(adventurer: selection))
                .border(.black)
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
        .fullScreenCover(isPresented: $biographyWizardShowing) {
            AdventurerWizard(wizardShowing: $biographyWizardShowing,
                             creatingNewCharacter: $creatingNewCharacter,
                             selection: selection)
        }
    }

    func edit() {
        biographyWizardShowing = true
    }
}

#Preview {
    return MainActor.assumeIsolated {
        AdventurerView(selection: .preview)
            .modelContainer(previewContainer)
    }
}
