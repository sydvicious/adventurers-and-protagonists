//
//  ContentView.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import SwiftUI
import SwiftData

struct Browser: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query(sort: [SortDescriptor(\Adventurer.name, comparator: .localized)]) var adventurers: [Adventurer]
    
    @State private var selection: Adventurer?
    
    // Sheets
    @State private var welcomeScreenShowing = false
    @State private var wizardShowing = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(adventurers) { item in
                    NavigationLink {
                        Text("\(item.name)")
                    } label: {
                        Text(item.name)
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
        } detail: {
            AdventurerView(selection: selection)
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear(perform: {
            let defaults = UserDefaults.standard
            welcomeScreenShowing = !defaults.bool(forKey: "WelcomeScreenShown")
            if self.horizontalSizeClass == .regular && self.selection == nil && self.adventurers.count > 0 {
                self.selection = self.adventurers[0]
            }
            if self.adventurers.count == 0 {
                welcomeScreenShowing = true
            }
        })
        .sheet(isPresented: $welcomeScreenShowing, content:{
            WelcomeScreen(welcomeScreenShowing: $welcomeScreenShowing)
        })
        .sheet(isPresented: $wizardShowing, content:{
            AdventurerWizard(wizardShowing: $wizardShowing, selection: $selection)
        })
    }

    private func addItem() {
        wizardShowing = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(adventurers[index])
            }
        }
    }
}

#Preview {
    UserDefaults.standard.set(true, forKey: "WelcomeScreenShown")
    return MainActor.assumeIsolated {
        Browser()
            .modelContainer(previewContainer)
    }
}
