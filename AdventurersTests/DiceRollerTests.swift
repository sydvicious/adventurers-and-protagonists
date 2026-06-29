//
//  DiceRollerTests.swift
//  AdventurersTests
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

@testable import Adventurers
import XCTest

nonisolated final class DiceRollerTests: XCTestCase {

    @MainActor
    func testSigned() {
        XCTAssertEqual(DiceRoller.signed(4), "+4")
        XCTAssertEqual(DiceRoller.signed(0), "+0")
        XCTAssertEqual(DiceRoller.signed(-3), "-3")
    }

    // MARK: - Checks (saves / ability checks)

    @MainActor
    func testCheckIsSingleLineWithTitle() {
        let result = DiceRoller.check(title: "Reflex save", modifier: 2)
        XCTAssertEqual(result.title, "Reflex save")
        XCTAssertEqual(result.lines.count, 1)
        XCTAssertTrue(result.lines[0].breakdown.hasPrefix("d20"), result.lines[0].breakdown)
        XCTAssertTrue(result.lines[0].breakdown.contains("+2"), result.lines[0].breakdown)
    }

    @MainActor
    func testCheckShowsSituationalModifier() {
        let result = DiceRoller.check(title: "Will save", modifier: 3, situational: 2)
        XCTAssertTrue(result.lines[0].breakdown.contains("situational +2"), result.lines[0].breakdown)
    }

    @MainActor
    func testCheckOmitsSituationalWhenZero() {
        let result = DiceRoller.check(title: "Will save", modifier: 3, situational: 0)
        XCTAssertFalse(result.lines[0].breakdown.contains("situational"), result.lines[0].breakdown)
    }

    // MARK: - Weapon rolls

    @MainActor
    func testWeaponRollFlankingAppearsInToHitBreakdown() {
        let result = DiceRoller.weaponRoll(
            title: "Sword", toHit: 5, damage: "1d8",
            threatRange: 21, critMultiplier: 2,
            extras: [RollModifier(label: "flanking", value: 2)])
        XCTAssertTrue(result.lines[0].breakdown.contains("flanking +2"), result.lines[0].breakdown)
    }

    @MainActor
    func testWeaponRollHighlightsToHitOnThreat() {
        let threat = DiceRoller.weaponRoll(
            title: "Sword", toHit: 5, damage: "1d8",
            threatRange: 1, critMultiplier: 2, extras: [])
        XCTAssertTrue(threat.lines[0].highlighted)
    }

    // MARK: - Damage parsing

    @MainActor
    func testRollDamageConstant() {
        XCTAssertEqual(DiceRoller.rollDamage("7")?.total, 7)
    }

    @MainActor
    func testRollDamageWithBonusInRange() throws {
        for _ in 0..<500 {
            let total = try XCTUnwrap(DiceRoller.rollDamage("1d8+4")?.total)
            XCTAssertGreaterThanOrEqual(total, 5)
            XCTAssertLessThanOrEqual(total, 12)
        }
    }

    @MainActor
    func testRollDamageSubtractionInRange() throws {
        for _ in 0..<500 {
            let total = try XCTUnwrap(DiceRoller.rollDamage("2d6-1")?.total)
            XCTAssertGreaterThanOrEqual(total, 1)
            XCTAssertLessThanOrEqual(total, 11)
        }
    }

    @MainActor
    func testRollDamageReturnsNilForUnparseable() {
        XCTAssertNil(DiceRoller.rollDamage(""))
        XCTAssertNil(DiceRoller.rollDamage("   "))
        XCTAssertNil(DiceRoller.rollDamage("sword"))
    }

    // MARK: - Critical damage (PF1e multiplies the whole expression)

    @MainActor
    func testCritDamageMultipliesConstant() {
        XCTAssertEqual(DiceRoller.rollDamage("3", times: 3)?.total, 9)
    }

    @MainActor
    func testCritDamageInRange() throws {
        for _ in 0..<500 {
            let total = try XCTUnwrap(DiceRoller.rollDamage("1d8+4", times: 3)?.total)
            XCTAssertGreaterThanOrEqual(total, 15)   // 3 × (1+4)
            XCTAssertLessThanOrEqual(total, 36)       // 3 × (8+4)
        }
    }

    @MainActor
    func testCritDamageBreakdownMarksCritical() {
        let breakdown = DiceRoller.rollDamage("1d8", times: 2)?.breakdown ?? ""
        XCTAssertTrue(breakdown.contains("×2"), breakdown)
        XCTAssertTrue(breakdown.contains("critical"), breakdown)
    }
}
