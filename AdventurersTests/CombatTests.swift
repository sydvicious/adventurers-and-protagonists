//
//  CombatTests.swift
//  AdventurersTests
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

@testable import Adventurers
import XCTest

nonisolated final class CombatTests: XCTestCase {

    @MainActor
    func testRollInitiativeStaysInRange() {
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.initiativeBonus = 3
        for _ in 0..<500 {
            let roll = adventurer.rollInitiative()
            XCTAssertGreaterThanOrEqual(roll, 1 + 3)
            XCTAssertLessThanOrEqual(roll, 20 + 3)
        }
    }

    @MainActor
    func testRollInitiativeHandlesNegativeBonus() {
        let adventurer = Adventurer(name: "Slow", abilities: [])
        adventurer.initiativeBonus = -2
        for _ in 0..<200 {
            let roll = adventurer.rollInitiative()
            XCTAssertGreaterThanOrEqual(roll, 1 - 2)
            XCTAssertLessThanOrEqual(roll, 20 - 2)
        }
    }

    @MainActor
    func testDamageTakenReflectsCurrentHP() {
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.maxHP = 10
        adventurer.currentHP = 10
        XCTAssertEqual(adventurer.damageTaken, 0)
        adventurer.currentHP = 6
        XCTAssertEqual(adventurer.damageTaken, 4)
    }

    @MainActor
    func testSettingDamageTakenAdjustsCurrentHP() {
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.maxHP = 10
        adventurer.currentHP = 10
        adventurer.damageTaken = 4
        XCTAssertEqual(adventurer.currentHP, 6)
    }

    @MainActor
    func testDamageTakenCanExceedMaxForNegativeHP() {
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.maxHP = 10
        adventurer.currentHP = 10
        adventurer.damageTaken = 13          // more than max → current goes below 0
        XCTAssertEqual(adventurer.currentHP, -3)
    }

    @MainActor
    func testNegativeDamageHealsToFull() {
        let adventurer = Adventurer(name: "Thora", abilities: [])
        adventurer.maxHP = 10
        adventurer.currentHP = 4
        adventurer.damageTaken = -5          // clamps to 0 damage → full HP, never above max
        XCTAssertEqual(adventurer.currentHP, 10)
    }
}
