//
//  Item.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
