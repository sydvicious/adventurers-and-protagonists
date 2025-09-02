//
//  MacBrowser.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//  Copyright ©2023-2025 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

// At some point, this needs a view model. At that point I will
// have to mess with Combine. The upside is that I can write a true data
// broker, and have one based on SwiftData, one based on sqlite, etc.

#if os(macOS)
struct MacBrowser: View {
    @Environment(\.modelContext) private var modelContext
    
    private let welcomeScreenShown: Bool
    private let viewModel: BrowserViewModel
    
    init(welcomeScreenShown: Bool,
         viewModel: BrowserViewModel) {
        self.welcomeScreenShown = welcomeScreenShown
        self.viewModel = viewModel
    }
    
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
    @State private var newItemID: PersistentIdentifier?

    // Sheets
    @State private var welcomeScreenShowing = false
    @State private var wizardShowing = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ZStack {
                List(selection: $selection) {
                    ForEach(adventurers) { item in
                        let id = item.persistentModelID
                        NavigationLink(value: id) {
                            Text(item.name)
                        }
                        .tag(id)
                        .contextMenu {
                            Button("Delete \(item.name)") {
                                delete(ids: [id])
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(ids: [id])
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Adventurers")
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    deleteButton
                        .help("Delete Adventurer")
                }
                ToolbarItem(placement: .primaryAction) {
                    addButton
                        .help("Add Adventurer")
                }
            }
            .frame(minWidth: 200)
            .onAppear {
                if selection == nil {
                    resetSelection()
                }
            }
            .onChange(of: adventurers.map(\.persistentModelID)) { _, newIDs in
                if let sel = selection, !newIDs.contains(sel) {
                    selection = newIDs.first
                }
            }
            .onChange(of: newItemID) { _, newID in
                if let newID = newID {
                    selection = newID
                }
            }
        } detail: {
            if let item = viewModel.adventurerFromID(selection) {
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
            if !self.welcomeScreenShown && self.adventurers.count == 0 {
                self.welcomeScreenShowing = true
            }
        })
        .sheet(isPresented: $welcomeScreenShowing, content:{
            WelcomeScreen(welcomeScreenShowing: $welcomeScreenShowing)
        })
        .toolbarTitleDisplayMode(.inline)                // saves space
        .sheet(isPresented: $wizardShowing) {
            let wizardViewModel = WizardViewModel(proto: Proto())
            AdventurerWizard(wizardShowing: $wizardShowing, newItemID: $newItemID)
                .environmentObject(wizardViewModel)
        }
    }
    
    private func addItem() {
        wizardShowing = true
    }
    
    // One button definition for both platforms
    private var addButton: some View {
        Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
        }
        .labelStyle(.iconOnly)   // show only the symbol, keep accessibility text
        .controlSize(.small)     // smaller control = more likely to stay out of overflow
    }
    
    private var deleteButton: some View {
        Button(action: deleteSelection) {
            Label("Delete Item", systemImage: "trash")
        }
        .labelStyle(.iconOnly)   // show only the symbol, keep accessibility text
        .controlSize(.small)     // smaller control = more likely to stay out of overflow
    }
    
    private func resetSelection() {
        selection = adventurers.first?.persistentModelID
    }
    
    private func delete(adventurer: Adventurer) {
        if adventurer.persistentModelID == selection {
            resetSelection()
        }
        modelContext.delete(adventurer)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                delete(adventurer: adventurers[index])
            }
        }
    }
    
    private func delete(ids: [PersistentIdentifier]) {
        withAnimation {
            for id in ids {
                if let adventurer = viewModel.adventurerFromID(id) {
                    delete(adventurer: adventurer)
                }
            }
        }
    }
    
    private func deleteSelection() {
        if let selectedID = selection {
            delete(ids: [selectedID])
        }
    }
}

#Preview("Zero characters", traits: .fixedLayout(width: 1100, height: 800)) {
    let viewModel = BrowserViewModel(modelContext: emptyContainer.mainContext)
    let welcomeScreenShown = true

    return MacBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(emptyContainer)
}

#Preview("Zero characters, no welcome", traits: .fixedLayout(width: 1100, height: 800)) {
    let viewModel = BrowserViewModel(modelContext: emptyContainer.mainContext)
    let welcomeScreenShown = false

    return MacBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(emptyContainer)
}

#Preview("One character", traits: .fixedLayout(width: 1100, height: 800)) {
    let viewModel = BrowserViewModel(modelContext: previewContainer.mainContext)
    let welcomeScreenShown = true

    return MacBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(previewContainer)
}

#Preview("One character; no welcome", traits: .fixedLayout(width: 1100, height: 800)) {
    let viewModel = BrowserViewModel(modelContext: previewContainer.mainContext)
    let welcomeScreenShown = false
    
    return MacBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(previewContainer)
}
#endif

