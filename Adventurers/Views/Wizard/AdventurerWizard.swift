//
//  CreateAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

struct AdventurerWizard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var wizardShowing: Bool
    @Binding var creatingNewCharacter: Bool // need to set this to false when returning.
    @Binding var selection: Adventurer?

    @State private var proto = Proto.dummyProtoData()

    @State private var doneDisabled = true
    @State private var biographyReady = false

    var body: some View {
        ScrollView {
            VStack {
                Text(creatingNewCharacter ? "Create a new adventurer" : "Edit Character")
                    .font(.title)
            }
        }
        .defaultScrollAnchor(.top)
        HStack {
            Button("Cancel", action: cancel)
            Button("Done", action: done)
                .disabled(doneDisabled)
        }
        .onAppear {
            if !creatingNewCharacter, let selection = selection {
                proto = Proto(from: selection)
            }
            updateDoneButton()
        }
    }

    private func updateDoneButton() {
        doneDisabled = proto.name.isTrimmedStringEmpty()
    }

    private func cancel() {
        wizardShowing = false
        creatingNewCharacter = false
    }

    private func setName() {

    }

    private func done() {
        let adventurer = proto.adventurerFrom(usePoints: false)
        if let adventurer {
            withAnimation {
                modelContext.insert(adventurer)
            }
            selection = adventurer
            wizardShowing = false
            creatingNewCharacter = false
        } else {
            updateDoneButton()
        }
    }

}

#Preview {
    @State var wizardShowing = true
    @State var selection: Adventurer? = nil
    @State var creatingNewCharacter = true

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: $selection)
            .modelContainer(previewContainer)
    }
}

#Preview {
    @State var wizardShowing = true
    @State var selection: Adventurer? = SampleData.adventurers[0]
    @State var creatingNewCharacter = false

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, creatingNewCharacter: $creatingNewCharacter, selection: $selection)
            .modelContainer(previewContainer)
    }
}
