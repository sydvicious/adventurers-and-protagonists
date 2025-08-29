//
//  BrowserViewModel.swift
//  Adventurers
//
//  Created by Syd Polk on 8/25/25.
//

import SwiftUI
import SwiftData

/**
 This is not strictly a view model yet. It's a set of methods that works with the model context shared by the iOS and Mac versions of the Adventurer Browser.
 */

class BrowserViewModel {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func adventurerFromID(_ id: PersistentIdentifier?) -> Adventurer? {
        if let id, let item = (modelContext.model(for: id)) as? Adventurer {
            return item
        }
        return nil
    }
    
    func adventuterNameFromID(_ id: PersistentIdentifier?) -> String? {
        if let adventurer = self.adventurerFromID(id) {
            return adventurer.name
        }
        return nil
    }
}
