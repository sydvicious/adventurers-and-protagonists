//
//  PreviewModelContainer.swift
//  Adventurers
//
//  Created by Syd Polk on 7/5/23.
//  Copyright ©2023 Syd Polk. All rights reserved.
//

import Foundation
import SwiftData

let previewContainer: ModelContainer = {
    let schema = Schema([
        Adventurer.self,
        Ability.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

        for adventurer in SampleData.adventurers {
            container.mainContext.insert(adventurer)
        }
        return container
    } catch {
        fatalError("Failed to create preview container")
    }
}()
