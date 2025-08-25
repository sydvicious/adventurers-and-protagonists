//
//  Ability.swift
//  Adventurers
//
//  Created by Syd Polk on 7/28/23.
//  Copyright ©2023-2025 Syd Polk. All rights reserved.
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
    var label: String
    var score: Int

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
    
    public static func sortedByLabel(abilities: [Ability]) -> [Ability] {
        var sortedAbilities: [AbilityLabels:Ability] = [:]
        
        for ability in abilities {
            if let label = AbilityLabels(rawValue: ability.label) {
                sortedAbilities[label] = ability
            }
        }
        
        var abilitiesToReturn: [Ability] = []
        
        for label in AbilityLabels.allCases {
            if let ability = sortedAbilities[label] {
                abilitiesToReturn.append(ability)
            }
        }
        
        return abilitiesToReturn
    }
}
