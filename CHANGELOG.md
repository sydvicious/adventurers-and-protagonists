# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Combat mode** — a distinct player-side HUD living in the character's **Combat tab**
  (vision §5c; separate from the future GM combat tracker). The tab shows a "Roll
  Initiative" prompt until a fight starts; then the HUD runs as a **persistent session** —
  kept per character in a store, so switching tabs *or* navigating away (e.g. back to the
  list) and returning resumes the same fight (round, modifiers, hands). **End combat** ends
  it. **Round**, **End my turn**, and **End combat** sit in the nav bar.
  Shows the initiative roll; an **HP panel** with a single **[−] damage / max [+]** line
  (set damage by stepper or typing, the same big size as max; damage may exceed max), a
  secondary current-HP readout that turns **red at 0 or below**, temp HP, and a bar; a
  **To Hit** panel; defenses; and one-tap
  **saving-throw** and **ability-check** rolls (a **natural 1 or 20** highlights the total
  in red).
  - **To Hit panel** — combines the roll modifiers (a **Flanking (+2)** toggle and a
    generic **situational modifier**) with **Primary Hand** and **Off-Hand** weapon pickers
    (choices are the character's attacks, a stand-in for inventory until equipment ships),
    each with its own roll button.
  - **One roll does it all** — rolling a hand's weapon shows a result **sheet** with each
    total in bold over its composition: **to-hit**, **damage**, and on a natural **critical
    threat** the **crit-confirmation roll** and **crit damage** as well (order: to-hit ·
    crit threat · crit damage · damage). On a threat the to-hit total is shown in **red**.
    Crit damage multiplies the whole expression per PF1e (not just the dice as in 5e). No
    separate Attacks panel in combat — the hand pickers cover it.
  - An "End my turn" button advances the round counter. HP and roll logic live on the model
    (`Adventurer.rollInitiative()`, `applyDamage`/`applyHeal`) and a shared `RollResult` /
    `DiceRoller` layer used by both the sheet and combat mode.
  - Deferred to later subsystems/phases: the Cast / Use item / Use skill action bar,
    active-effect round counters, class resources as spend-counters, action-economy
    tracking, and campaign-attached auto-entry over sync.
- **Held weapon** — `Attack.isHeldWeapon` flag plus `Adventurer.heldWeapon` and
  `Adventurer.setHeldWeapon(_:)`, marking the single attack to be rolled by the quick /
  Apple Watch "roll held weapon" action (falls back to the first attack when none is
  flagged). Data-model groundwork for the future Apple Watch combat companion; the flag
  round-trips through the character editor. Editor UI to choose the held weapon is still
  to come.
- **Critical threat range** — `Attack.threatRange` (the natural-d20 low end, default 20),
  editable in the transcribe editor and shown in the attack summary when wider than a
  natural 20 (e.g. "18–20/×2"). Drives critical-confirmation rolls in combat mode.

### Changed
- **Tabbed character detail** — opening a character now shows a tab bar: **Overview** (the
  sheet), **Combat** (the HUD), and **Other** (a placeholder for Biography / Equipment /
  Skills / Spells / Journal — vision §5c). Replaces pushing combat onto the nav stack; the
  combat session persists across tab switches.
- **Consistent collapsible panels** — the character sheet and the combat HUD now use one
  shared `CollapsiblePanel` (a titled panel with a disclosure triangle), so both read the
  same way and every panel can be collapsed/expanded. The sheet moved from a grouped
  `Form` to a scrolling stack of these panels.
- **Width / grid layout** — the Overview and the combat HUD fill the available width (no
  more big iPad margins) and, on wide views (iPad/Mac), lay their panels out in **two
  columns**; iPhone stays single-column. On the Overview the header and the six-across
  ability grid span the full width; in combat the status spans and the ability checks stay
  within a column. The ability-score and ability-check grids snap to a divisor of six
  columns (6, 3, 2, or 1) by width via a new `ColumnGrid`, instead of an awkward 4 or 5.
- **macOS character editor** — rebuilt as a scrollable two-column layout grouped by
  section, with an explicit bottom Cancel/Save bar. Cancel (and the Esc key) dismiss
  without saving. Fixes the macOS editor sheet that previously couldn't scroll or be
  dismissed.

- **Overview has no Attacks panel** — attacks are entered in the editor and rolled from the
  Combat tab's Primary/Off-Hand; the Overview is a clean reference of the core stats.
- **Remembers the selected character** — the character on screen is saved (by `uid` in
  `@AppStorage`) and reselected on next launch.

### Fixed
- **One Hit Points panel everywhere** — the Overview and Combat tabs now render the same
  shared `HitPointsPanel` (the `[−] damage / max [+]` design), so they're identical and
  can't drift. HP-damage logic lives in `Adventurer.damageTaken`.
- **Combat HP control fits on iPhone** — the `[−] damage / max [+]` row no longer clips
  (smaller step buttons, a content-sized damage field, scalable max).
- **Edit raw data is easy to find** — the Overview header now has a labeled **Edit** button
  (in addition to the toolbar pencil), which was easy to miss inside the tabbed detail on
  iPad.

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
