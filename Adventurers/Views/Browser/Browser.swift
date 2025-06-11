//
//  Browser.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

// At some point, this needs a view model. At that point I will
// have to mess with Combine. The upside is that I can write a true data
// broker, and have one based on SwiftData, one based on sqlite, etc.

struct Browser: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query var rawAdventurers: [Adventurer]
    var adventurers : [Adventurer] {
        rawAdventurers.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
    
    @State private var columnVisibility =
        NavigationSplitViewVisibility.all
    @State private var selection: Adventurer?

    // Sheets
    @State private var welcomeScreenShowing = false
    @State private var wizardShowing = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selection) {
                ForEach(adventurers) { item in
                    NavigationLink {
                        AdventurerView(selection: item)
                    }
                    label: {
                        Text("\(item.name)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Adventurers")
            .onAppear {
                if self.horizontalSizeClass == .regular && self.selection == nil && self.adventurers.count > 0 {
                    self.selection = self.adventurers[0]
                }
            }

        } detail: {
            if let selection {
                AdventurerView(selection: selection)
            } else {
                Text("Please select an adventurer from the list or hit the + button to add a new one.")
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear(perform: {
            let defaults = UserDefaults.standard
            welcomeScreenShowing = !defaults.bool(forKey: "WelcomeScreenShown")
            if self.adventurers.count == 0 {
                welcomeScreenShowing = true
            }
        })
        .sheet(isPresented: $welcomeScreenShowing, content:{
            WelcomeScreen(welcomeScreenShowing: $welcomeScreenShowing)
        })
        #if os(iOS)
        .fullScreenCover(isPresented: $wizardShowing) {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                let wizardViewModel = WizardViewModel(proto: Proto(from: selection))
                AdventurerWizard(wizardShowing: $wizardShowing)
                    .environmentObject(wizardViewModel)
            }
        }
        #endif
    }

    private func addItem() {
        wizardShowing = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(adventurers[index])
                Task {
                    do {
                        try modelContext.save()
                    } catch {
                        fatalError("Could not save modelContext: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    UserDefaults.standard.set(true, forKey: "WelcomeScreenShown")
    return Browser()
        .modelContainer(previewContainer)
}
