//
//  AdventurerView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

struct AdventurerView: View {
    @State var selection: Adventurer
    @State private var creatingNewCharacter = false
    @State private var biographyWizardShowing =  false
    @State private var isReady = true
    @State private var isNewCharacter = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text(selection.name)
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    .border(.black)

                AbilitiesView(isReady: $isReady,
                              isNewCharacter: $isNewCharacter,
                              abilities: $selection.abilities)
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
