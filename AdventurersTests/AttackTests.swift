//
//  AttackTests.swift
//  AdventurersTests
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

@testable import Adventurers
import XCTest

nonisolated final class AttackTests: XCTestCase {

    @MainActor
    func testSigned() {
        XCTAssertEqual(Attack.signed(5), "+5")
        XCTAssertEqual(Attack.signed(0), "+0")
        XCTAssertEqual(Attack.signed(-2), "-2")
    }

    @MainActor
    func testMeleeSummaryLine() {
        let attack = Attack(name: "+1 Warhammer", toHit: 9, damage: "1d8+4", critMultiplier: 3, range: 0)
        XCTAssertEqual(attack.summaryLine, "+9 · 1d8+4 · ×3")
    }

    @MainActor
    func testRangedSummaryLineIncludesRange() {
        let attack = Attack(name: "Throwing axe", toHit: 6, damage: "1d6+3", critMultiplier: 2, range: 10)
        XCTAssertEqual(attack.summaryLine, "+6 · 1d6+3 · ×2 · 10 ft")
    }

    @MainActor
    func testSummaryLineOmitsBlankDamage() {
        let attack = Attack(name: "Slam", toHit: 0, damage: "   ", critMultiplier: 2, range: 0)
        XCTAssertEqual(attack.summaryLine, "+0 · ×2")
    }

    @MainActor
    func testAttackRollResultTotalAndMessage() {
        let result = AttackRollResult(attackName: "Axe", d20: 15, toHit: 6, damage: "1d6+3")
        XCTAssertEqual(result.total, 21)
        XCTAssertTrue(result.message.contains("Axe"))
        XCTAssertTrue(result.message.contains("d20: 15"))
        XCTAssertTrue(result.message.contains("+6"))
        XCTAssertTrue(result.message.contains("21 to hit"), result.message)
        XCTAssertTrue(result.message.contains("Damage: 1d6+3"))
    }

    @MainActor
    func testAttackRollResultMessageOmitsBlankDamage() {
        let result = AttackRollResult(attackName: "Unarmed", d20: 3, toHit: 2, damage: "")
        XCTAssertFalse(result.message.contains("Damage:"))
    }
}
