//
//  AbilityTests.swift
//  AdventurersTests
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

@testable import Adventurers
import XCTest

nonisolated final class AbilityTests: XCTestCase {

    @MainActor
    func testModifierMath() {
        XCTAssertEqual(Ability.modifier(value: 10), 0)
        XCTAssertEqual(Ability.modifier(value: 11), 0)   // floor(0.5)
        XCTAssertEqual(Ability.modifier(value: 18), 4)
        XCTAssertEqual(Ability.modifier(value: 16), 3)
        XCTAssertEqual(Ability.modifier(value: 9), -1)   // floor(-0.5)
        XCTAssertEqual(Ability.modifier(value: 8), -1)
        XCTAssertEqual(Ability.modifier(value: 7), -2)   // floor(-1.5)
        XCTAssertEqual(Ability.modifier(value: 1), -5)
    }

    @MainActor
    func testModifierStringHasExplicitSign() {
        XCTAssertEqual(Ability.modifierString(value: 18), "+4")
        XCTAssertEqual(Ability.modifierString(value: 10), "+0")
        XCTAssertEqual(Ability.modifierString(value: 8), "-1")
        XCTAssertEqual(Ability.modifierString(value: 1), "-5")
    }

    @MainActor
    func testSortedByLabelUsesDeclarationOrder() {
        // Intentionally out of order; expect AbilityLabels.allCases order:
        // Strength, Constitution, Dexterity, Intelligence, Wisdom, Charisma.
        let scrambled = [
            Ability(label: AbilityLabels.cha.rawValue, score: 8),
            Ability(label: AbilityLabels.str.rawValue, score: 16),
            Ability(label: AbilityLabels.wis.rawValue, score: 13),
            Ability(label: AbilityLabels.dex.rawValue, score: 12),
            Ability(label: AbilityLabels.int.rawValue, score: 10),
            Ability(label: AbilityLabels.con.rawValue, score: 14),
        ]
        let sorted = Ability.sortedByLabel(abilities: scrambled)
        XCTAssertEqual(sorted.map(\.label), [
            "Strength", "Constitution", "Dexterity", "Intelligence", "Wisdom", "Charisma",
        ])
        XCTAssertEqual(sorted.first?.score, 16)
        XCTAssertEqual(sorted.last?.score, 8)
    }

    @MainActor
    func testSortedByLabelDropsUnknownLabels() {
        let abilities = [
            Ability(label: AbilityLabels.str.rawValue, score: 16),
            Ability(label: "Luck", score: 20),
        ]
        let sorted = Ability.sortedByLabel(abilities: abilities)
        XCTAssertEqual(sorted.count, 1)
        XCTAssertEqual(sorted.first?.label, "Strength")
    }
}
