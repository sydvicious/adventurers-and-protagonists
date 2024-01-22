//
//  AdventurerView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

struct AdventurerView: View {
    @State var selection: Adventurer?

    @State private var creatingNewCharacter = false
    @State private var showParentIfWizardCancelled = true

    @State private var biographyWizardShowing =  false
    @State private var proto: Proto = Proto.dummyProtoData()

    var body: some View {
        if let selection {
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
                                 selection: $selection)
            }
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
