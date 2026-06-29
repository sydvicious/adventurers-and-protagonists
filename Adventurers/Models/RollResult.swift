//
//  RollResult.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import Foundation

/// One labeled total with the breakdown that produced it. Shown as a bold total with its
/// composition beneath.
struct RollLine {
    /// "To hit", "Crit threat — confirm", "Crit damage (×3)", "Damage", or "" for a check.
    let label: String
    let total: String
    /// The composition shown under the total (may span multiple lines).
    let breakdown: String
    /// Render the total in a warning colour — used for a critical threat's to-hit roll.
    var highlighted: Bool = false
}

/// The outcome of a roll, shown to the player. One or more `RollLine`s — a save/ability
/// check is a single line; a weapon roll is the to-hit, then (on a natural threat) the
/// crit-confirmation roll and crit damage, then normal damage.
struct RollResult: Identifiable {
    let id = UUID()
    let title: String
    let lines: [RollLine]
}

/// A named flat modifier applied to a d20 roll (e.g. flanking +2, a situational
/// bonus/penalty). PF1e uses flat circumstance modifiers rather than 5e advantage.
struct RollModifier {
    let label: String
    let value: Int
}

/// Pure dice helpers backing the at-the-table roll buttons.
enum DiceRoller {
    static func signed(_ value: Int) -> String {
        value < 0 ? "\(value)" : "+\(value)"
    }

    /// Rolls a d20 with a modifier and named extras. Returns the natural die, the total,
    /// and a breakdown like "d20 15 · +9 · flanking +2" (no total — that's shown bold).
    @MainActor
    private static func rollD20(modifier: Int, extras: [RollModifier]) -> (natural: Int, total: Int, breakdown: String) {
        let natural = Dice.rawRoll(dieType: 20)
        let extrasTotal = extras.reduce(0) { $0 + $1.value }
        var parts = ["d20 \(natural)", signed(modifier)]
        for extra in extras where extra.value != 0 {
            parts.append("\(extra.label) \(signed(extra.value))")
        }
        return (natural, natural + modifier + extrasTotal, parts.joined(separator: " · "))
    }

    /// A d20 check (saving throw, ability check): a single-line result.
    @MainActor
    static func check(title: String, modifier: Int, situational: Int = 0) -> RollResult {
        let extras = situational != 0 ? [RollModifier(label: "situational", value: situational)] : []
        let roll = rollD20(modifier: modifier, extras: extras)
        let extreme = roll.natural == 1 || roll.natural == 20
        var breakdown = roll.breakdown
        if extreme {
            breakdown += roll.natural == 20 ? "  ·  natural 20!" : "  ·  natural 1!"
        }
        return RollResult(title: title, lines: [
            RollLine(label: "", total: "\(roll.total)", breakdown: breakdown, highlighted: extreme),
        ])
    }

    /// A full weapon roll: to-hit (with a PF1e critical-confirmation roll folded into its
    /// breakdown on a natural threat), normal damage, and — on a threat — crit damage
    /// (the whole expression × the multiplier, PF1e-style).
    @MainActor
    static func weaponRoll(title: String,
                           toHit: Int,
                           damage: String,
                           threatRange: Int,
                           critMultiplier: Int,
                           extras: [RollModifier]) -> RollResult {
        let hit = rollD20(modifier: toHit, extras: extras)
        let threatens = hit.natural >= threatRange
        let extreme = hit.natural == 1 || hit.natural == 20
        var hitBreakdown = hit.breakdown
        if extreme {
            hitBreakdown += hit.natural == 20 ? "  ·  natural 20!" : "  ·  natural 1!"
        }

        // Order: attack roll, then (on a threat) the confirmation roll and crit damage,
        // then normal damage. The to-hit total is highlighted on a threat or a natural 1/20.
        var lines = [RollLine(label: "To hit",
                              total: "\(hit.total)",
                              breakdown: hitBreakdown,
                              highlighted: threatens || extreme)]
        if threatens {
            let confirm = rollD20(modifier: toHit, extras: extras)
            lines.append(RollLine(label: "Crit threat — confirm",
                                  total: "\(confirm.total)",
                                  breakdown: confirm.breakdown))
            if let critRoll = rollDamage(damage, times: critMultiplier) {
                lines.append(RollLine(label: "Crit damage (×\(critMultiplier))",
                                      total: "\(critRoll.total)",
                                      breakdown: critRoll.breakdown))
            }
        }
        if let damageRoll = rollDamage(damage, times: 1) {
            lines.append(RollLine(label: "Damage", total: "\(damageRoll.total)", breakdown: damageRoll.breakdown))
        }
        return RollResult(title: title, lines: lines)
    }

    /// Rolls a free-text damage expression like "1d8+4". With `times` > 1 (a PF1e
    /// critical) the whole expression is rolled that many times and summed. Returns the
    /// total and a breakdown, or nil if nothing parses.
    @MainActor
    static func rollDamage(_ expression: String, times: Int = 1) -> (total: Int, breakdown: String)? {
        let cleaned = expression.replacingOccurrences(of: " ", with: "")
        guard !cleaned.isEmpty, times >= 1 else { return nil }
        let trimmed = expression.trimmingCharacters(in: .whitespaces)

        if times == 1 {
            guard let once = rollDamageOnce(cleaned) else { return nil }
            var breakdown = trimmed
            if !once.diceNotes.isEmpty {
                breakdown += "   (\(once.diceNotes.joined(separator: ", ")))"
            }
            return (once.total, breakdown)
        }

        var grandTotal = 0
        var perRoll: [Int] = []
        for _ in 0..<times {
            guard let once = rollDamageOnce(cleaned) else { return nil }
            grandTotal += once.total
            perRoll.append(once.total)
        }
        return (grandTotal, "\(trimmed) ×\(times) (critical)   (rolls: \(perRoll))")
    }

    /// Rolls a whitespace-stripped damage expression once. Returns the total and a note
    /// of which dice came up, or nil if nothing in the expression parses.
    @MainActor
    private static func rollDamageOnce(_ cleaned: String) -> (total: Int, diceNotes: [String])? {
        var total = 0
        var diceNotes: [String] = []
        var parsedAnything = false
        var current = ""
        var sign = 1

        func flushTerm() {
            defer { current = "" }
            guard !current.isEmpty else { return }
            let body = current.lowercased()
            if body.contains("d") {
                let comps = body.split(separator: "d", maxSplits: 1, omittingEmptySubsequences: false)
                let count = comps[0].isEmpty ? 1 : Int(comps[0])
                let sides = comps.count > 1 ? Int(comps[1]) : nil
                guard let count, let sides, count > 0, count <= 100, sides > 0 else { return }
                let rolls = (0..<count).map { _ in Dice.rawRoll(dieType: sides) }
                total += sign * rolls.reduce(0, +)
                diceNotes.append("\(count)d\(sides): \(rolls)")
                parsedAnything = true
            } else if let constant = Int(body) {
                total += sign * constant
                parsedAnything = true
            }
        }

        for character in cleaned {
            if character == "+" || character == "-" {
                flushTerm()
                sign = (character == "-") ? -1 : 1
            } else {
                current.append(character)
            }
        }
        flushTerm()

        return parsedAnything ? (total, diceNotes) : nil
    }
}

extension Attack {
    /// A non-empty display name for the attack.
    var displayName: String { name.isEmpty ? "Attack" : name }

    /// A full weapon roll for this attack — to-hit, damage, and crit damage on a threat.
    /// `handLabel` (e.g. "Primary Hand") prefixes the title; `extras` carries flanking and
    /// any situational modifier.
    @MainActor
    func weaponRoll(handLabel: String? = nil, extras: [RollModifier] = []) -> RollResult {
        let title = handLabel.map { "\($0) — \(displayName)" } ?? displayName
        return DiceRoller.weaponRoll(title: title,
                                     toHit: toHit,
                                     damage: damage,
                                     threatRange: threatRange,
                                     critMultiplier: critMultiplier,
                                     extras: extras)
    }
}
