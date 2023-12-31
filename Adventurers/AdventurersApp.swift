//
//  AdventurersApp.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
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
        WindowGroup {
            Browser()
        }
        .modelContainer(sharedModelContainer)
    }
}
