//
//  CombatTabView.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

/// The Combat tab. With no fight in progress it shows a "Roll Initiative" prompt; once a
/// fight is running it shows the combat HUD. Session state is owned by CharacterTabsView,
/// so leaving the tab keeps the fight going.
struct CombatTabView: View {
    @Bindable var adventurer: Adventurer
    @Bindable var session: CombatSession

    var body: some View {
        if session.isRunning {
            CombatModeView(adventurer: adventurer, session: session)
        } else {
            ContentUnavailableView {
                Label("No Combat in Progress", systemImage: "shield.lefthalf.filled")
            } description: {
                Text("Roll initiative to start a fight.")
            } actions: {
                Button("Roll Initiative") {
                    session.start(initiative: adventurer.rollInitiative())
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Combat")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}
