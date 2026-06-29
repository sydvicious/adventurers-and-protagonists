//
//  CharacterTabsView.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

/// The per-character detail: a tab bar over the character's surfaces. For now Overview
/// (the sheet), Combat (the HUD), and Other (a placeholder for Biography / Equipment /
/// Skills / Spells / Journal — vision §5c). Combat-session state lives here so switching
/// tabs never ends the fight or loses anything.
struct CharacterTabsView: View {
    @Bindable var adventurer: Adventurer

    @Environment(CombatSessionStore.self) private var combatStore
    @State private var selection: Tab = .overview

    private enum Tab: Hashable { case overview, combat, other }

    var body: some View {
        // The session is owned by the store (keyed by character), so it persists whether or
        // not the character is on screen.
        let session = combatStore.session(for: adventurer.persistentModelID)
        TabView(selection: $selection) {
            NavigationStack {
                AdventurerView(selection: adventurer)
            }
            .tabItem { Label("Overview", systemImage: "person.text.rectangle") }
            .tag(Tab.overview)

            NavigationStack {
                CombatTabView(adventurer: adventurer, session: session)
            }
            .tabItem { Label("Combat", systemImage: "shield.lefthalf.filled") }
            .tag(Tab.combat)

            NavigationStack {
                OtherTabView()
            }
            .tabItem { Label("Other", systemImage: "ellipsis.circle") }
            .tag(Tab.other)
        }
    }
}

#if DEBUG
#Preview {
    CharacterTabsView(adventurer: .preview)
        .environment(CombatSessionStore())
        .modelContainer(previewContainer)
}
#endif
