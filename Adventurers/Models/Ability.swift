//
//  Ability.swift
//  Adventurers
//
//  Created by Syd Polk on 7/28/23.
//

import Foundation
import SwiftData

enum AbilityLabels: String, CaseIterable {
    case str = "Strength"
    case con = "Constitution"
    case dex = "Dexterity"
    case int = "Intelligence"
    case wis = "Wisdown"
    case cha = "Charisma"
}

@Model
final class Ability {
    var label: String;
    var score: Int;

    init(label: String, score: Int) {
        self.label = label
        self.score = score
    }
}
