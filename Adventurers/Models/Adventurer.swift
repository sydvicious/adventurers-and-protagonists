//
//  Item.swift
//  Adventurers
//
//  Created by Syd Polk on 7/4/23.
//  Copyright ©2023-2025 Syd Polk. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Adventurer  {
    var timestamp: Date = Date()
    var uid: UUID = UUID()
    var name: String = ""
    var abilities: [Ability] = []
    @Transient var abilitiesMap: [AbilityLabels:Ability] = [:]

    // MARK: Identity (transcribe free-text)
    var ancestry: String = ""
    /// Free-text class & level, e.g. "Fighter 5".
    var classAndLevel: String = ""
    /// Free-text alignment, e.g. "LG" or "Lawful Good".
    var alignment: String = ""

    // MARK: Hit points
    var maxHP: Int = 0
    var currentHP: Int = 0
    var tempHP: Int = 0

    // MARK: Defenses
    var armorClass: Int = 10
    var touchAC: Int = 10
    var flatFootedAC: Int = 10

    // MARK: Saving throws
    var fortitude: Int = 0
    var reflex: Int = 0
    var will: Int = 0

    // MARK: Combat
    var baseAttackBonus: Int = 0
    var cmb: Int = 0
    var cmd: Int = 10
    var initiativeBonus: Int = 0
    /// Speed in feet.
    var speed: Int = 30

    // MARK: Notes
    var notes: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Attack.adventurer)
    var attacks: [Attack] = []

    init(name: String, abilities: [Ability]) {
        self.timestamp = Date()
        self.uid = UUID()
        self.name = name
        self.abilities = abilities
        self.currentHP = self.maxHP
    }

    /// Attacks in the order the player entered them.
    var sortedAttacks: [Attack] {
        attacks.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// The attack used by the quick / Apple Watch "roll held weapon" action: the
    /// one flagged as held, falling back to the first attack so there's always
    /// something to roll when the character has any attacks.
    var heldWeapon: Attack? {
        sortedAttacks.first { $0.isHeldWeapon } ?? sortedAttacks.first
    }

    /// Marks one attack as the held weapon and clears the flag on the rest, so at
    /// most one attack is ever held.
    func setHeldWeapon(_ attack: Attack) {
        for candidate in attacks {
            candidate.isHeldWeapon = (candidate === attack)
        }
    }

    /// "Dwarf Fighter 5" — used as the list subtitle. Empty if nothing entered.
    var lineage: String {
        [ancestry, classAndLevel]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// "Dwarf Fighter 5 · Lawful Good" — used as the sheet header subtitle.
    var headerSubtitle: String {
        let alignmentText = alignment.trimmingCharacters(in: .whitespaces)
        return [lineage, alignmentText]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    @MainActor
    func updateFromProto(_ proto: Proto) {
        updateName(proto)
        updateAbilities(proto)
    }

    @MainActor
    private func updateName(_ proto: Proto) {
        if self.name != proto.name {
            self.name = proto.name
        }
    }

    @MainActor
    private func updateAbilities (_ proto: Proto) {
            struct Scores {
                var stored: Int?
                var proto: Int?
            }
            var scores: [String: Scores] = [:]
            var newAbilities: [Ability] = []
            
            AbilityLabels.allCases.forEach {
                let score = Scores(stored: nil, proto: nil)
                scores[$0.rawValue] = score
            }
            
            proto.abilities.forEach {
                let label = $0.label
                let protoScore = $0.score
                var comparedScore = scores[label]
                comparedScore?.proto = protoScore
                scores[label] = comparedScore
            }
            
            self.abilities.forEach {
                let label = $0.label
                let storedScore = $0.score
                var comparedScore = scores[label]
                comparedScore?.stored = storedScore
                scores[label] = comparedScore
            }
            
            var writeAbilities = false
            scores.forEach { label, comparedScore in
                if let protoScore = comparedScore.proto {
                    if let _ = comparedScore.stored {
                        writeAbilities = true
                    }
                    newAbilities.append(Ability(label: label, score: protoScore))
                }
            }
            
            if writeAbilities {
                self.abilities = newAbilities
            }
    }

    #if DEBUG
    @MainActor static let preview: Adventurer = {
        var abilities = [Ability]()
        abilities.append(Ability(label: AbilityLabels.str.rawValue, score: 16))
        abilities.append(Ability(label: AbilityLabels.dex.rawValue, score: 12))
        abilities.append(Ability(label: AbilityLabels.con.rawValue, score: 16))
        abilities.append(Ability(label: AbilityLabels.int.rawValue, score: 10))
        abilities.append(Ability(label: AbilityLabels.wis.rawValue, score: 13))
        abilities.append(Ability(label: AbilityLabels.cha.rawValue, score: 8))
        let adventurer = Adventurer(name: "Thora Ironfist", abilities: abilities)
        adventurer.ancestry = "Dwarf"
        adventurer.classAndLevel = "Fighter 5"
        adventurer.alignment = "Lawful Good"
        adventurer.maxHP = 44
        adventurer.currentHP = 44
        adventurer.tempHP = 0
        adventurer.armorClass = 19
        adventurer.touchAC = 11
        adventurer.flatFootedAC = 18
        adventurer.fortitude = 7
        adventurer.reflex = 2
        adventurer.will = 2
        adventurer.baseAttackBonus = 5
        adventurer.cmb = 8
        adventurer.cmd = 19
        adventurer.initiativeBonus = 1
        adventurer.speed = 20
        adventurer.notes = "Stonecunning; +2 vs. poison, spells, and SLAs. Hatred: +1 attack vs. orcs and goblinoids."
        adventurer.attacks = [
            Attack(name: "+1 Warhammer", toHit: 9, damage: "1d8+4", critMultiplier: 3, range: 0, sortOrder: 0, isHeldWeapon: true),
            Attack(name: "Throwing axe", toHit: 6, damage: "1d6+3", critMultiplier: 2, range: 10, sortOrder: 1),
        ]
        return adventurer
    }()
    #endif
}
