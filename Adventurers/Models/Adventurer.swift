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
    var abilities: [Ability]

    init(name: String, abilities: [Ability]) {
        self.timestamp = Date()
        self.uid = UUID()
        self.name = name
        self.abilities = abilities
    }
    
    #if DEBUG
    static let preview: Adventurer = {
        var abilities = [Ability]()
        abilities.append(Ability(label: AbilityLabels.str.rawValue, score: 17))
        abilities.append(Ability(label: AbilityLabels.dex.rawValue, score: 15))
        abilities.append(Ability(label: AbilityLabels.con.rawValue, score: 12))
        abilities.append(Ability(label: AbilityLabels.int.rawValue, score: 9))
        abilities.append(Ability(label: AbilityLabels.wis.rawValue, score: 7))
        abilities.append(Ability(label: AbilityLabels.cha.rawValue, score: 21))
        return Adventurer(name: "Pendecar", abilities: abilities)
    }()
    #endif
}
