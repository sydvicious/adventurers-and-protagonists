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
    var body: some Scene {
        WindowGroup {
            Browser()
        }
        .modelContainer(for: Adventurer.self)
    }
}
