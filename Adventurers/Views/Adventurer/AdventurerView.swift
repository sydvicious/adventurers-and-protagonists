//
//  AdventurerView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

struct AdventurerView: View {
    var selection: Adventurer
    @State private var creatingNewCharacter = false
    @State private var biographyWizardShowing =  false

    var body: some View {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    VStack {
                        Text(selection.name)
                    }
                    .padding()
                    .frame(width: geometry.size.width)
                    .frame(height: geometry.size.height)
                }
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
