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
    
    @Query private var rawAdventurers: [Adventurer]
    private var adventurers: [Adventurer] {
        rawAdventurers.sorted { lhs, rhs in
            let result = lhs.name.compare(
                rhs.name,
                options: [.caseInsensitive, .diacriticInsensitive, .numeric], // <- key bits
                range: nil,
                locale: .current
            )
            if result == .orderedSame {
                // tie-break to keep order stable when names equal ignoring case/diacritics
                return lhs.uid.uuidString < rhs.uid.uuidString
            }
            return result == .orderedAscending
        }
    }

    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selection: PersistentIdentifier?

    // Sheets
    @State private var welcomeScreenShowing = false
    @State private var wizardShowing = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selection) {
                ForEach(adventurers) { item in
                    let id = item.persistentModelID
                    NavigationLink(value: id) {
                        Text(item.name)
                    }
                    .tag(id)
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                // iOS/iPadOS: right side of the nav bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
#elseif os(macOS)
                // macOS: put it in the actual toolbar (not the overflow)
                ToolbarItem(placement: .primaryAction) {
                    addButton
                        .help("Add Item") // nice tooltip on macOS
                }
#endif
            }
#if os(macOS)
            .frame(minWidth: 200)
#endif
            .onAppear {
                if horizontalSizeClass == .regular, selection == nil {
                    selection = adventurers.first?.persistentModelID
                }
            }
            .onChange(of: adventurers.map(\.persistentModelID)) { _, newIDs in
                if let sel = selection, !newIDs.contains(sel) {
                    selection = newIDs.first
                }
            }
        } detail: {
            if let item = adventurerFromID(selection) {
                GeometryReader { proxy in
                    Group {
                        AdventurerView(selection: item)
                            .contentMargins(.horizontal, 0, for: .scrollContent)
                            .navigationTitle(item.name)
                            .toolbarTitleDisplayMode(.inline)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                }
            } else {
                Text("Please select an adventurer from the list or hit the + button to add a new one.")
            }
        }
        .navigationSplitViewStyle(.balanced)
        .navigationTitle("Adventurers")
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
                let wizardViewModel = WizardViewModel(proto: Proto())
                AdventurerWizard(wizardShowing: $wizardShowing)
                    .environmentObject(wizardViewModel)
            }
        }
        #else
        .toolbarTitleDisplayMode(.inline)                // saves space
        .sheet(isPresented: $wizardShowing) {
            let wizardViewModel = WizardViewModel(proto: Proto())
            AdventurerWizard(wizardShowing: $wizardShowing)
                .environmentObject(wizardViewModel)
        }
        #endif
    }

    private func adventurerFromID(_ id: PersistentIdentifier?) -> Adventurer? {
        if let id, let item = (modelContext.model(for: id)) as? Adventurer {
            return item
        }
        return nil
    }
    
    private func addItem() {
        wizardShowing = true
    }
    
    // One button definition for both platforms
    private var addButton: some View {
        Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
        }
#if os(macOS)
        .labelStyle(.iconOnly)   // show only the symbol, keep accessibility text
        .controlSize(.small)     // smaller control = more likely to stay out of overflow
#else
        .labelStyle(.iconOnly)
#endif
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(adventurers[index])
            }
            do {
                try modelContext.save()
            } catch {
                fatalError("Could not save modelContext: \(error)")
            }
        }
    }
}

#Preview {
    UserDefaults.standard.set(true, forKey: "WelcomeScreenShown")
    return Browser()
        .modelContainer(previewContainer)
}
