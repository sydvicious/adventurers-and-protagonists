//
//  CreateAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 11/23/23.
//

import SwiftUI

struct CreateAdventurerWizard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var wizardShowing: Bool
    @Binding var selection: Adventurer?

    @State private var proto = Proto.dummyProtoData()

    @State private var doneDisabled = true
    @State private var nameValid = false

    var body: some View {
        ScrollView {
            VStack {
                Text("Create a new adventurer")
                    .font(.title)
                Spacer()
                BiographyWizard(proto: $proto,
                                nameValid: $nameValid)
            }
        }
        .defaultScrollAnchor(.top)
        HStack {
            Button("Cancel", action: cancel)
            Button("Done", action: done)
                .disabled(doneDisabled)
        }
    }


    private func updateDoneButton() {
        doneDisabled = !(nameValid)
    }

    private func cancel() {
        wizardShowing = false
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
        } else {
            updateDoneButton()
        }
    }

}

#Preview {
    @State var wizardShowing = true
    @State var selection: Adventurer? = nil

    return MainActor.assumeIsolated {
        CreateAdventurerWizard(wizardShowing: $wizardShowing, selection: $selection)
            .modelContainer(previewContainer)
    }
}
