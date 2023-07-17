//
//  PreviewModelContainer.swift
//  Adventurers
//
//  Created by Syd Polk on 7/5/23.
//

import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Adventurer.self, ModelConfiguration(inMemory: true))
                
        for adventurer in SampleData.adventurers {
            container.mainContext.insert(object: adventurer)
        }
        return container
    } catch {
        fatalError("Failed to create preview container")
    }
}()
