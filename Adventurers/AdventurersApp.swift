//
//  AdventurersApp.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//  Copyright ©2023 Syd Polk. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct AdventurersApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Adventurer.self,
            Ability.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        let defaults = UserDefaults.standard
        let welcomeScreenShown = !defaults.bool(forKey: "WelcomeScreenShown")
        let browserViewModel = BrowserViewModel(modelContext: sharedModelContainer.mainContext)

        return WindowGroup {
            #if os(iOS)
            IOSBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: browserViewModel)
            #else
            // Enforce a minimum content size for the window on macOS
            MacBrowser(welcomeScreenShown: welcomeScreenShown, viewModel: browserViewModel)
                .frame(minWidth: 600, minHeight: 400)
            #endif
        }
        #if os(macOS)
        // Set a sensible default window size for macOS
        .defaultSize(width: 1100, height: 800)
        // Respect the content's minimum size when resizing the window
        .windowResizability(.contentSize)
        #endif
        .modelContainer(sharedModelContainer)
    }
}
