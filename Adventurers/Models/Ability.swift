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
    case wis = "Wisdom"
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

    public static func modifier(value: Int) -> Int {
        let normalized : Double = Double(value - 10)
        let half = normalized / 2.0
        let result = floor(half)
        return Int(result)
    }

    public static func modifierString(value: Int) -> String {
        let modifier = Self.modifier(value: value)
        if modifier < 0 {
            return String(modifier)
        }
        return "+" + String(modifier)
    }
}
