//
//  AdventurerTests.swift
//  AdventurersTests
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

@testable import Adventurers
import XCTest

nonisolated final class AdventurerTests: XCTestCase {

    @MainActor
    private func makeAdventurer() -> Adventurer {
        Adventurer(name: "Thora", abilities: [])
    }

    @MainActor
    func testLineageJoinsAncestryAndClass() {
        let adventurer = makeAdventurer()
        adventurer.ancestry = "Dwarf"
        adventurer.classAndLevel = "Fighter 5"
        XCTAssertEqual(adventurer.lineage, "Dwarf Fighter 5")
    }

    @MainActor
    func testLineageSkipsEmptyParts() {
        let adventurer = makeAdventurer()
        adventurer.ancestry = ""
        adventurer.classAndLevel = "Fighter 5"
        XCTAssertEqual(adventurer.lineage, "Fighter 5")

        adventurer.classAndLevel = ""
        XCTAssertEqual(adventurer.lineage, "")
    }

    @MainActor
    func testHeaderSubtitleAppendsAlignment() {
        let adventurer = makeAdventurer()
        adventurer.ancestry = "Dwarf"
        adventurer.classAndLevel = "Fighter 5"
        adventurer.alignment = "Lawful Good"
        XCTAssertEqual(adventurer.headerSubtitle, "Dwarf Fighter 5 · Lawful Good")
    }

    @MainActor
    func testHeaderSubtitleWithoutAlignment() {
        let adventurer = makeAdventurer()
        adventurer.ancestry = "Dwarf"
        adventurer.classAndLevel = "Fighter 5"
        adventurer.alignment = "   "
        XCTAssertEqual(adventurer.headerSubtitle, "Dwarf Fighter 5")
    }

    @MainActor
    func testHeaderSubtitleEmptyWhenNothingSet() {
        XCTAssertEqual(makeAdventurer().headerSubtitle, "")
    }

    @MainActor
    func testHeldWeaponPrefersFlagged() {
        let adventurer = makeAdventurer()
        adventurer.attacks = [
            Attack(name: "Hammer", sortOrder: 0),
            Attack(name: "Axe", sortOrder: 1, isHeldWeapon: true),
        ]
        XCTAssertEqual(adventurer.heldWeapon?.name, "Axe")
    }

    @MainActor
    func testHeldWeaponFallsBackToFirst() {
        let adventurer = makeAdventurer()
        adventurer.attacks = [
            Attack(name: "Second", sortOrder: 1),
            Attack(name: "First", sortOrder: 0),
        ]
        XCTAssertEqual(adventurer.heldWeapon?.name, "First")
    }

    @MainActor
    func testHeldWeaponNilWhenNoAttacks() {
        XCTAssertNil(makeAdventurer().heldWeapon)
    }

    @MainActor
    func testSetHeldWeaponClearsOthers() {
        let adventurer = makeAdventurer()
        let hammer = Attack(name: "Hammer", sortOrder: 0, isHeldWeapon: true)
        let axe = Attack(name: "Axe", sortOrder: 1)
        adventurer.attacks = [hammer, axe]

        adventurer.setHeldWeapon(axe)

        XCTAssertFalse(hammer.isHeldWeapon)
        XCTAssertTrue(axe.isHeldWeapon)
        XCTAssertEqual(adventurer.attacks.filter(\.isHeldWeapon).count, 1)
        XCTAssertEqual(adventurer.heldWeapon?.name, "Axe")
    }

    @MainActor
    func testSortedAttacksOrdersBySortOrder() {
        let adventurer = makeAdventurer()
        adventurer.attacks = [
            Attack(name: "Second", sortOrder: 1),
            Attack(name: "Third", sortOrder: 2),
            Attack(name: "First", sortOrder: 0),
        ]
        XCTAssertEqual(adventurer.sortedAttacks.map(\.name), ["First", "Second", "Third"])
    }
}
