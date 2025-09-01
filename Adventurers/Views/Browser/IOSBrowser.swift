//
//  Browser.swift
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

#if os(iOS)
struct IOSBrowser: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
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
    @State private var isShowingNewWizard = false

    var body: some View {
        NavigationStack {
            NavigationSplitView(columnVisibility: $columnVisibility) {
            ZStack {
                List(selection: $selection) {
                    ForEach(adventurers) { item in
                        let id = item.persistentModelID
                        NavigationLink(value: id) {
                            Text(item.name)
                        }
                        .tag(id)
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
                if horizontalSizeClass == .compact && adventurers.isEmpty {
                    Text("Use the + button in the upper right corner to create your first adventurer!")
                        .padding(40)
                }
            }
            .navigationTitle("Adventurers")
            .toolbar {
                if horizontalSizeClass == .regular {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        deleteButton
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    lightningBoltButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
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
        .onAppear(perform: {
            if !self.welcomeScreenShown && self.adventurers.count == 0 {
                self.welcomeScreenShowing = true
            }
        })
        .sheet(isPresented: $welcomeScreenShowing, content:{
            WelcomeScreen(welcomeScreenShowing: $welcomeScreenShowing)
        })
        .fullScreenCover(isPresented: $wizardShowing) {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                let wizardViewModel = WizardViewModel(proto: Proto())
                AdventurerWizard(wizardShowing: $wizardShowing, newItemID: $newItemID)
                    .environmentObject(wizardViewModel)
            }
        }
        .navigationDestination(isPresented: $isShowingNewWizard) {
            NewAdventurerWizard()
        }
        }
    }

    private func addItem() {
        wizardShowing = true
    }
    
    private func addNewWizardItem() {
        isShowingNewWizard = true
    }
    
    // One button definition for both platforms
    private var addButton: some View {
        Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
        }
        .labelStyle(.iconOnly)
    }
    
    private var deleteButton: some View {
        Button(action: deleteSelection) {
            Label("Delete Item", systemImage: "trash")
        }
        .labelStyle(.iconOnly)
    }
    
    private var lightningBoltButton: some View {
        Button(action: addNewWizardItem) {
            Label("New Wizard", systemImage: "bolt")
        }
        .labelStyle(.iconOnly)
    }
    
    private func resetSelection() {
        if horizontalSizeClass == .regular {
            selection = adventurers.first?.persistentModelID
        }
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

#Preview("Zero characters") {
    let viewModel = BrowserViewModel(modelContext: emptyContainer.mainContext)
    let welcomeScreenShown = true
    
    return IOSBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(emptyContainer)
}

#Preview("Zero characters, no welcome") {
    let viewModel = BrowserViewModel(modelContext: emptyContainer.mainContext)
    let welcomeScreenShown = false
    
    return IOSBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(emptyContainer)
}

#Preview("One character") {
    let viewModel = BrowserViewModel(modelContext: previewContainer.mainContext)
    let welcomeScreenShown = true
    
    return IOSBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(previewContainer)
}

#Preview("One character; no welcome") {
    let viewModel = BrowserViewModel(modelContext: previewContainer.mainContext)
    let welcomeScreenShown = false
    
    return IOSBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: viewModel)
        .modelContainer(previewContainer)
}
#endif

