//
//  Attack.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import Foundation
import SwiftData

/// A single attack "line" on the basic-combatant sheet: a name, a to-hit bonus,
/// a free-text damage expression, a critical multiplier, and an optional ranged
/// increment. Consistent with the transcribe-only v1 — nothing here is derived
/// from equipped gear; the values are entered directly.
@Model
final class Attack {
    var name: String = ""
    /// The to-hit modifier, e.g. +9.
    var toHit: Int = 0
    /// Free-text damage expression, e.g. "1d8+4". Not parsed in v1.
    var damage: String = ""
    /// Critical multiplier (the "×3" / "×2"). Defaults to the d20 norm of ×2.
    var critMultiplier: Int = 2
    /// Range increment in feet for thrown/ranged attacks. 0 means melee.
    var range: Int = 0
    /// Preserves the order the player entered attacks in.
    var sortOrder: Int = 0
    /// Marks the character's held weapon — the one rolled by the quick/Apple Watch
    /// "roll held weapon" action. At most one attack per character should be held
    /// (maintained by `Adventurer.setHeldWeapon(_:)`).
    var isHeldWeapon: Bool = false

    // Optional inverse back-reference keeps the schema CloudKit-legal.
    var adventurer: Adventurer?

    init(name: String = "",
         toHit: Int = 0,
         damage: String = "",
         critMultiplier: Int = 2,
         range: Int = 0,
         sortOrder: Int = 0,
         isHeldWeapon: Bool = false) {
        self.name = name
        self.toHit = toHit
        self.damage = damage
        self.critMultiplier = critMultiplier
        self.range = range
        self.sortOrder = sortOrder
        self.isHeldWeapon = isHeldWeapon
    }

    /// The compact "+9 · 1d8+4 · ×3 · 10 ft" line shown under the attack name.
    var summaryLine: String {
        var parts: [String] = [Self.signed(toHit)]
        if !damage.trimmingCharacters(in: .whitespaces).isEmpty {
            parts.append(damage)
        }
        parts.append("×\(critMultiplier)")
        if range > 0 {
            parts.append("\(range) ft")
        }
        return parts.joined(separator: " · ")
    }

    static func signed(_ value: Int) -> String {
        value < 0 ? "\(value)" : "+\(value)"
    }
}
