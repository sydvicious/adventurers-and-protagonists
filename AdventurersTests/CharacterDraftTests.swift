//
//  CharacterDraftTests.swift
//  AdventurersTests
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

@testable import Adventurers
import SwiftData
import XCTest

nonisolated final class CharacterDraftTests: XCTestCase {

    // Uses an explicit ModelContext rather than container.mainContext: on the
    // macOS 27 beta unit-test host, inserting into mainContext traps inside
    // SwiftData. A standalone ModelContext over the same in-memory container
    // works (and the app itself uses mainContext via SwiftUI at runtime).
    @MainActor
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Adventurer.self, Ability.self, Attack.self,
            configurations: config)
        return ModelContext(container)
    }

    // MARK: - New draft

    @MainActor
    func testNewDraftDefaults() {
        let draft = CharacterDraft(from: nil)
        XCTAssertTrue(draft.isNew)
        XCTAssertEqual(draft.abilities.count, 6)
        XCTAssertEqual(draft.abilities.first?.label, "Strength")
        XCTAssertTrue(draft.abilities.allSatisfy { $0.score == 10 })
        XCTAssertEqual(draft.maxHP, 0)
        XCTAssertEqual(draft.armorClass, 10)
        XCTAssertTrue(draft.attacks.isEmpty)
    }

    @MainActor
    func testCanSaveRequiresNonBlankName() {
        let draft = CharacterDraft(from: nil)
        XCTAssertFalse(draft.canSave)
        draft.name = "   "
        XCTAssertFalse(draft.canSave)
        draft.name = "Thora"
        XCTAssertTrue(draft.canSave)
    }

    // MARK: - Draft from existing adventurer

    @MainActor
    func testDraftFromAdventurerCopiesFields() throws {
        let context = try makeContext()
        let adventurer = Adventurer(name: "Thora", abilities: [
            Ability(label: AbilityLabels.str.rawValue, score: 16),
        ])
        adventurer.ancestry = "Dwarf"
        adventurer.classAndLevel = "Fighter 5"
        adventurer.maxHP = 44
        adventurer.armorClass = 19
        adventurer.attacks = [Attack(name: "Hammer", toHit: 9, damage: "1d8+4", critMultiplier: 3, sortOrder: 0)]
        context.insert(adventurer)

        let draft = CharacterDraft(from: adventurer)
        XCTAssertFalse(draft.isNew)
        XCTAssertEqual(draft.name, "Thora")
        XCTAssertEqual(draft.ancestry, "Dwarf")
        XCTAssertEqual(draft.maxHP, 44)
        XCTAssertEqual(draft.armorClass, 19)
        XCTAssertEqual(draft.attacks.count, 1)
        XCTAssertEqual(draft.attacks.first?.name, "Hammer")
    }

    @MainActor
    func testDraftFillsMissingAbilitiesWithTen() throws {
        let context = try makeContext()
        // Only Strength provided; the other five should default to 10, in order.
        let adventurer = Adventurer(name: "Partial", abilities: [
            Ability(label: AbilityLabels.str.rawValue, score: 18),
        ])
        context.insert(adventurer)

        let draft = CharacterDraft(from: adventurer)
        XCTAssertEqual(draft.abilities.count, 6)
        XCTAssertEqual(draft.abilities.map(\.label), [
            "Strength", "Constitution", "Dexterity", "Intelligence", "Wisdom", "Charisma",
        ])
        XCTAssertEqual(draft.abilities.first?.score, 18)
        XCTAssertEqual(draft.abilities.dropFirst().map(\.score), [10, 10, 10, 10, 10])
    }

    // MARK: - apply()

    @MainActor
    func testApplyNewSetsCurrentHPToMax() throws {
        let context = try makeContext()
        let draft = CharacterDraft(from: nil)
        draft.name = "  Hero  "
        draft.maxHP = 25

        let adventurer = Adventurer(name: "", abilities: [])
        context.insert(adventurer)
        draft.apply(to: adventurer, in: context)

        XCTAssertEqual(adventurer.name, "Hero")          // trimmed
        XCTAssertEqual(adventurer.maxHP, 25)
        XCTAssertEqual(adventurer.currentHP, 25)         // new → full HP
        XCTAssertEqual(adventurer.abilities.count, 6)
    }

    @MainActor
    func testApplyEditClampsCurrentHPWhenMaxLowered() throws {
        let context = try makeContext()
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.maxHP = 44
        adventurer.currentHP = 44
        context.insert(adventurer)

        let draft = CharacterDraft(from: adventurer)
        draft.maxHP = 30
        draft.apply(to: adventurer, in: context)

        XCTAssertEqual(adventurer.maxHP, 30)
        XCTAssertEqual(adventurer.currentHP, 30)         // clamped down
    }

    @MainActor
    func testApplyEditKeepsCurrentHPWhenMaxRaised() throws {
        let context = try makeContext()
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.maxHP = 44
        adventurer.currentHP = 40
        context.insert(adventurer)

        let draft = CharacterDraft(from: adventurer)
        draft.maxHP = 50
        draft.apply(to: adventurer, in: context)

        XCTAssertEqual(adventurer.maxHP, 50)
        XCTAssertEqual(adventurer.currentHP, 40)         // not auto-healed
    }

    @MainActor
    func testApplyReconcilesAttacksAndReindexes() throws {
        let context = try makeContext()
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.attacks = [
            Attack(name: "Hammer", sortOrder: 0),
            Attack(name: "Axe", sortOrder: 1),
        ]
        context.insert(adventurer)

        let draft = CharacterDraft(from: adventurer)
        XCTAssertEqual(draft.attacks.count, 2)
        draft.attacks.removeFirst()                      // drop "Hammer"; keep "Axe"
        draft.apply(to: adventurer, in: context)

        XCTAssertEqual(adventurer.attacks.count, 1)
        XCTAssertEqual(adventurer.sortedAttacks.first?.name, "Axe")
        XCTAssertEqual(adventurer.sortedAttacks.first?.sortOrder, 0)   // reindexed from 1 → 0
    }
}
