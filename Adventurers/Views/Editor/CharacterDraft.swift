//
//  CharacterDraft.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import Foundation
import SwiftData

/// An editable in-memory copy of a basic-combatant character, used by the
/// transcribe editor. It is not a SwiftData model: edits only touch persistent
/// state when the player taps Save, so Cancel discards cleanly.
@Observable
final class CharacterDraft {
    // Identity
    var name = ""
    var ancestry = ""
    var classAndLevel = ""
    var alignment = ""

    // Ability scores, ordered STR, CON, DEX, INT, WIS, CHA (AbilityLabels order).
    var abilities: [ProtoAbility]

    // Hit points (only the max is transcribed; current/temp are live on the sheet).
    var maxHP = 0

    // Defenses
    var armorClass = 10
    var touchAC = 10
    var flatFootedAC = 10

    // Saving throws
    var fortitude = 0
    var reflex = 0
    var will = 0

    // Combat
    var baseAttackBonus = 0
    var cmb = 0
    var cmd = 10
    var initiativeBonus = 0
    var speed = 30

    // Notes
    var notes = ""

    // Attacks
    var attacks: [AttackDraft] = []

    /// True when building a brand-new character (vs. editing an existing one).
    let isNew: Bool

    init(from adventurer: Adventurer?) {
        guard let adventurer else {
            isNew = true
            abilities = Proto.baseAbilities()
            return
        }
        isNew = false
        name = adventurer.name
        ancestry = adventurer.ancestry
        classAndLevel = adventurer.classAndLevel
        alignment = adventurer.alignment
        abilities = CharacterDraft.orderedAbilities(from: adventurer.abilities)
        maxHP = adventurer.maxHP
        armorClass = adventurer.armorClass
        touchAC = adventurer.touchAC
        flatFootedAC = adventurer.flatFootedAC
        fortitude = adventurer.fortitude
        reflex = adventurer.reflex
        will = adventurer.will
        baseAttackBonus = adventurer.baseAttackBonus
        cmb = adventurer.cmb
        cmd = adventurer.cmd
        initiativeBonus = adventurer.initiativeBonus
        speed = adventurer.speed
        notes = adventurer.notes
        attacks = adventurer.sortedAttacks.map { AttackDraft(from: $0) }
    }

    /// The player can save once the name is non-empty. Transcribe trusts the
    /// rest of the input, so there is no further validation in v1.
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addAttack() {
        attacks.append(AttackDraft())
    }

    /// Writes the draft back onto a persistent `Adventurer`. Caller is
    /// responsible for inserting a new adventurer into the context first.
    func apply(to adventurer: Adventurer, in context: ModelContext) {
        adventurer.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        adventurer.ancestry = ancestry
        adventurer.classAndLevel = classAndLevel
        adventurer.alignment = alignment

        // Replace abilities wholesale; the small fixed set makes this cheap.
        for old in adventurer.abilities {
            context.delete(old)
        }
        adventurer.abilities = abilities.map { Ability(label: $0.label, score: $0.score) }

        adventurer.maxHP = maxHP
        if isNew {
            adventurer.currentHP = maxHP
        } else if adventurer.currentHP > maxHP {
            adventurer.currentHP = maxHP
        }

        adventurer.armorClass = armorClass
        adventurer.touchAC = touchAC
        adventurer.flatFootedAC = flatFootedAC
        adventurer.fortitude = fortitude
        adventurer.reflex = reflex
        adventurer.will = will
        adventurer.baseAttackBonus = baseAttackBonus
        adventurer.cmb = cmb
        adventurer.cmd = cmd
        adventurer.initiativeBonus = initiativeBonus
        adventurer.speed = speed
        adventurer.notes = notes

        for old in adventurer.attacks {
            context.delete(old)
        }
        adventurer.attacks = attacks.enumerated().map { index, draft in
            Attack(name: draft.name.trimmingCharacters(in: .whitespaces),
                   toHit: draft.toHit,
                   damage: draft.damage.trimmingCharacters(in: .whitespaces),
                   critMultiplier: draft.critMultiplier,
                   range: draft.range,
                   sortOrder: index)
        }
    }

    private static func orderedAbilities(from abilities: [Ability]) -> [ProtoAbility] {
        var byLabel: [String: Int] = [:]
        for ability in abilities {
            byLabel[ability.label] = ability.score
        }
        return AbilityLabels.allCases.map { label in
            ProtoAbility(label: label.rawValue, score: byLabel[label.rawValue] ?? 10)
        }
    }
}

/// Editable copy of a single attack line.
struct AttackDraft: Identifiable {
    let id = UUID()
    var name = ""
    var toHit = 0
    var damage = ""
    var critMultiplier = 2
    var range = 0

    init() {}

    init(from attack: Attack) {
        name = attack.name
        toHit = attack.toHit
        damage = attack.damage
        critMultiplier = attack.critMultiplier
        range = attack.range
    }
}
