# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1] - 2026-06-28

Phase 1 of the roadmap (see `vision.md`): the standalone, offline, transcribe-only
Pathfinder 1e "basic combatant" character sheet.

### Added
- **Basic-combatant character sheet** — a scrolling stack of grouped cards showing
  ability scores with modifiers, hit points (current / max / temp) with in-place
  −/＋ steppers, defenses (AC / touch / flat-footed), saving throws, combat values
  (BAB, CMB, CMD, initiative, speed), attack lines, and notes.
- **Attacks** — entered as attack lines (name, to-hit, damage, critical multiplier,
  optional range), each with a one-tap d20 to-hit roll on the sheet.
- **Transcribe editor** — a single grouped form for creating and editing a character
  by entering values directly (minimal validation, no rules engine). Wired to the
  "+" (create) and Edit actions on both iOS and macOS.
- **Character list subtitle** — shows the ancestry/class lineage (e.g. "Dwarf Fighter 5").
- **Data model** — new `Attack` model; `Adventurer` extended with identity (ancestry,
  class & level, alignment), hit points, defenses, saving throws, combat values, notes,
  and an attacks relationship. Schema kept CloudKit-legal (scalar defaults, optional
  inverse relationship).
- **Tests** — 26 unit tests covering ability modifier math and sorting, attack-line
  formatting, adventurer lineage/subtitle, and the character-draft apply logic.

### Changed
- **Project structure** — migrated the Xcode project to file-system synchronized groups,
  so new source files in the source folders are included automatically (no manual
  `project.pbxproj` edits).
- **Deployment targets** — raised minimum to iOS 27.0 and macOS 27.0 for all targets.
- Creating and editing characters now uses the transcribe editor instead of the older
  multi-tab wizard (which is retained but no longer the create/edit path).

### Fixed
- Test targets compile under the project's default `MainActor` actor isolation
  (`XCTestCase` subclasses marked `nonisolated`; test methods that touch app types
  marked `@MainActor`).

### Notes
- The app builds for iOS and macOS. iOS simulators are unavailable in the current
  environment, so runtime verification is done on a physical device; macOS unit tests
  run natively.
- Deferred to later increments (per `vision.md`): skills, spells, conditions,
  equipment/encumbrance, the guided rules-driven wizard, leveling, AI-assist,
  print/PDF, accounts/sync/campaigns, and the combat tracker.
