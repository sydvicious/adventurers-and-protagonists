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
    var uid: UUID
    var name: String
    
    init(name: String) {
        self.timestamp = Date()
        self.uid = UUID()
        self.name = name
    }
    
    #if DEBUG
    static let preview: Adventurer = {
        Adventurer(name: "Pendecar")
    }()
    #endif
}