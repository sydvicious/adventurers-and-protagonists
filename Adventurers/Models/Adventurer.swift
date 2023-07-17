//
//  Item.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import Foundation
import SwiftData

@Model
final class Adventurer {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
    
    #if DEBUG
    static let preview: Adventurer = {
        Adventurer(timestamp: .now)
    }()
    #endif
}
