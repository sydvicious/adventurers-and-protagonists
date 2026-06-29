//
//  CombatSession.swift
//  Adventurers
//
//  Created by Syd Polk on 6/28/26.
//  Copyright ©2026 Syd Polk. All rights reserved.
//

import Foundation
import SwiftData

/// The live, in-memory state of one character's fight. Held by `CombatSessionStore` (not
/// in a view's `@State`) so it survives navigating away from and back to the character.
@Observable
final class CombatSession {
    var isRunning = false
    var initiativeRoll = 0
    var round = 1
    var situational = 0
    var flanking = false
    var primaryWeaponID: PersistentIdentifier?
    var offHandWeaponID: PersistentIdentifier?

    /// Begins a fresh fight, resetting the round and modifiers. Hand selections are left
    /// alone (re-seeded from the held weapon when the HUD appears if empty).
    func start(initiative: Int) {
        initiativeRoll = initiative
        round = 1
        situational = 0
        flanking = false
        isRunning = true
    }
}

/// Vends one `CombatSession` per character, keyed by its persistent id. Injected into the
/// environment at app launch so a character's combat state persists for the whole session,
/// whether or not the character is on screen.
@Observable
final class CombatSessionStore {
    @ObservationIgnored private var sessions: [PersistentIdentifier: CombatSession] = [:]

    func session(for id: PersistentIdentifier) -> CombatSession {
        if let existing = sessions[id] {
            return existing
        }
        let created = CombatSession()
        sessions[id] = created
        return created
    }
}
