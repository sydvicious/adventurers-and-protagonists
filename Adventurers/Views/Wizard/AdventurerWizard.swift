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
    @Binding var selection: Adventurer?

    @State private var proto = Proto.dummyProtoData()

    @State private var doneDisabled = true

    var body: some View {
        ScrollView {
            VStack {
                Text(selection == nil ? "Create a new adventurer" : "Edit Character")
                    .font(.title)
                Spacer()
                BiographyWizard(proto: $proto)
                    .onChange(of: proto) {
                        updateDoneButton()
                    }
            }
        }
        .defaultScrollAnchor(.top)
        HStack {
            Button("Cancel", action: cancel)
            Button("Done", action: done)
                .disabled(doneDisabled)
        }
        .onAppear {
            if let selection = selection {
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
        AdventurerWizard(wizardShowing: $wizardShowing, selection: $selection)
            .modelContainer(previewContainer)
    }
}

#Preview {
    @State var wizardShowing = true
    @State var selection: Adventurer? = SampleData.adventurers[0]

    return MainActor.assumeIsolated {
        AdventurerWizard(wizardShowing: $wizardShowing, selection: $selection)
            .modelContainer(previewContainer)
    }
}
