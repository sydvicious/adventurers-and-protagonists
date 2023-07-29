//
//  NewAdventurerWizard.swift
//  Adventurers
//
//  Created by Syd Polk on 7/23/23.
//

import SwiftUI

enum WizardFocus: Hashable {
    case name
}

enum WizardSectionNames: String {
    case name = "Name"
    /*
    case abilities = "Abilities"
    case race = "Race"
    case classes = "Classes"
    case skills = "Skills"
    case feats = "Feats"
    case equipment = "Equipment"
    case combat = "Combat"
    case spells = "Spells"
    case notes = "Notes"
     */
}

struct NewAdventurerWizard: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var wizardShowing: Bool
    @Binding var selection: Adventurer?
    
    @State private var proto = Proto.dummyProtoData()
    
    @State private var doneDisabled = true
    @State private var sectionsComplete: [WizardSectionNames:Bool] = [
        .name: false
    ]
    @State private var sectionSelected: WizardSectionNames? = .name
    @State private var sectionsColumnVisibility = NavigationSplitViewVisibility.doubleColumn

    @FocusState private var wizardFocus: WizardFocus?

    var body: some View {
        VStack {
            NavigationSplitView(columnVisibility: $sectionsColumnVisibility) {
                List(selection: $sectionSelected) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(proto.name).multilineTextAlignment(.trailing)
                        Text(sectionsComplete[.name] ?? false ? "✔️" : "❌").multilineTextAlignment(.trailing)
                    }
                }
            } detail: {
                if let sectionSelected {
                    switch sectionSelected {
                    case .name:
                        WizardNameView(proto: $proto, sectionsComplete: $sectionsComplete)
                    }
                }
            }
            HStack {
                Button("Cancel", action: cancel)
                Button("Done", action: done)
                    .disabled(doneDisabled)
            }
        }
    }
        
    private func validateName() {
        let trimmedName = proto.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        sectionsComplete[.name] = trimmedName != ""
    }

    private func updateDoneButton() {
        validateName()
        doneDisabled = !(sectionsComplete[.name] ?? false)
    }
    
    private func cancel() {
        wizardShowing = false
    }
    
    private func done() {
        let adventurer = proto.adventurerFrom()
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
        NewAdventurerWizard(wizardShowing: $wizardShowing, selection: $selection)
            .modelContainer(previewContainer)
    }
}

