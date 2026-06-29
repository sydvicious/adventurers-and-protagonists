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
    func testSummaryLineShowsWiderThreatRange() {
        let rapier = Attack(name: "Rapier", toHit: 5, damage: "1d6", critMultiplier: 2, threatRange: 18)
        XCTAssertEqual(rapier.summaryLine, "+5 · 1d6 · 18–20/×2")
    }

    @MainActor
    func testDisplayNameDefaultsForBlank() {
        XCTAssertEqual(Attack(name: "").displayName, "Attack")
        XCTAssertEqual(Attack(name: "Bow").displayName, "Bow")
    }

    @MainActor
    func testWeaponRollHasToHitAndDamageLines() {
        // threatRange 21 can never be hit, so only to-hit + damage appear.
        let result = Attack(name: "Bow", toHit: 6, damage: "1d8", threatRange: 21).weaponRoll()
        XCTAssertEqual(result.title, "Bow")
        XCTAssertEqual(result.lines.map(\.label), ["To hit", "Damage"])
    }

    @MainActor
    func testWeaponRollOmitsDamageLineWhenBlank() {
        let result = Attack(name: "Shove", toHit: 2, damage: "", threatRange: 21).weaponRoll()
        XCTAssertEqual(result.lines.map(\.label), ["To hit"])
    }

    @MainActor
    func testWeaponRollHandLabelPrefixesTitle() {
        let result = Attack(name: "Axe", toHit: 4, threatRange: 21).weaponRoll(handLabel: "Off-Hand")
        XCTAssertEqual(result.title, "Off-Hand — Axe")
    }

    @MainActor
    func testWeaponRollCritThreatLineOrderAndHighlight() {
        // threatRange 1 always threatens: order is to-hit, crit confirm, crit damage, damage.
        let result = Attack(name: "Scythe", toHit: 6, damage: "2d4", critMultiplier: 4, threatRange: 1).weaponRoll()
        XCTAssertEqual(result.lines.map(\.label),
                       ["To hit", "Crit threat — confirm", "Crit damage (×4)", "Damage"])
        XCTAssertTrue(result.lines[0].highlighted)   // to-hit total shown in red
    }

    @MainActor
    func testWeaponRollNoCritWhenThreatImpossible() {
        let result = Attack(name: "Club", toHit: 6, damage: "1d6", threatRange: 21).weaponRoll()
        XCTAssertEqual(result.lines.map(\.label), ["To hit", "Damage"])
        XCTAssertFalse(result.lines.contains { $0.label.contains("Crit") })
    }
}
