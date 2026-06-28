# TODO

Working backlog. The authoritative vision and rationale live in `vision.md`;
this is the actionable list. Roughly ordered: near-term first, then by roadmap phase.

## Bug Fixes
- [ ] On iPad and Mac, the left hand list view should not have the title of the app. Keep it on iPhone.

## Phase 1 — standalone character sheet (in progress)

The basic-combatant sheet + transcribe editor are done. Remaining to make the
character-sheet product truly shippable (internal order TBD):

- [ ] Skills subsystem
- [ ] Spells subsystem (PF1e spellcasting — large)
- [ ] Conditions
- [ ] Equipment / inventory, including encumbrance (carrying capacity, load penalties,
      armor-as-items)
- [ ] Guided / rules-driven wizard flavor + leveling (reuse the `creatures`
      Transactions/bonus engine; keep rules data separable from UI)
- [ ] AI-assisted flavor for narrative-only fields (on-device Foundation Models,
      with graceful fallback on unsupported hardware)
- [ ] Print / PDF export (paper-optimized layout reusing the sheet components)

### Combat mode — player-side HUD (vision §5c)
A distinct, screen-taking-over mode on the character sheet (NOT the Phase 2 GM combat
tracker). Deferred from the first v1 sheet; build after the core sheet. Several pieces
depend on the subsystems above (Cast → spells, Use item → equipment, Use skill → skills).
- [ ] Enter via a "Roll initiative" button (standalone); auto-triggered over sync when
      campaign-attached. Exit when combat ends / "End combat".
- [ ] Focused HUD: HP −/＋, defenses (AC/touch/flat-footed), attacks with a roll affordance
- [ ] Active effects with round counters (mirrors the GM tracker's spell durations, player side)
- [ ] Class resources as spend-counters (smite pips, lay on hands uses, spell slots)
- [ ] Action bar — Attack · Cast · Use item · Use skill (+ room for Feat/Ability/Other),
      each opening a focused picker as a bottom sheet → choose → execute
- [ ] Casting a duration spell spends the slot AND auto-creates a tracked active effect with
      a round counter; "Use item" decrements the consumable and applies its effect
- [ ] Action economy: start by just exposing the action buttons (optional quiet standard/
      move/swift hint); full economy tracking/enforcement is a later feature
- [ ] Apple Watch combat companion (later phase): out-of-combat shows name + avatar +
      "Roll initiative"; in-combat shows HP (Digital Crown) + the held-weapon attack.
      (Data-model readiness done: `Attack.isHeldWeapon` + `Adventurer.heldWeapon`/
      `setHeldWeapon(_:)`. Still TODO: editor UI to choose the held weapon.)

### Near-term polish / housekeeping
- [ ] Seed a couple of sample characters for on-device testing
- [ ] Decide temp-HP behavior on the sheet (currently steppers adjust current HP only;
      no damage-absorption rule yet — full absorption is a Phase 2 combat-tracker concern)
- [ ] Replace remaining default template tests (`testExample` Proto test, UI-test
      templates) with real ones, or remove them
- [ ] Decide the fate of the retained wizards (`Archive/Old Wizard` and the 10-tab
      `NewAdventurerWizard`) now that the transcribe editor is the create/edit path
- [ ] Review now-unused views after the sheet rewrite (`AdventurerViewModel`,
      `AbilitiesView`/`AbilityGridRowView`) — keep, repurpose, or remove
- [ ] iPad/Mac layout pass — adapt the iPhone-first sheet to multi-column where it helps
- [ ] Accessibility audit — VoiceOver labels, Dynamic Type at large sizes, contrast

### Open decisions (from vision.md §10 and §5a)
- [ ] PF1e reference data: hand-enter vs. ingest an open dataset (PCGen/SRD). Only needs
      an answer when the guided wizard requires the full rules corpus.
- [ ] Study **PathCompanion** (closest competitor) before locking remaining Phase-1 scope —
      match table stakes, find the 1–2 weak spots that point at the larger vision.
- [ ] Settle the hardest at-the-table UI question early: keeping the active turn +
      initiative list readable/operable at arm's length (feeds Phase 2).

## Mac platform (after the first build is complete)
- [ ] Convert the Mac app to a **document-based app**. Keep a panel/sidebar listing the
      characters, but opening a character opens it in its own **new window** — so Mac users
      can view several characters at once. Makes the app feel more Mac-like.

## Technical foundations (bake in early, per vision §4)
- [ ] Spike CloudKit early (the main technical risk; only new piece of the stack).
      Schema is already kept CloudKit-legal.
- [ ] Localization foundations: String Catalogs, no string concatenation, locale-aware
      number/dice formatting (ship English-only, stay i18n-ready).
- [ ] RTL correctness: use leading/trailing everywhere; test with the RTL pseudolanguage.
- [ ] Semantic color/token layer (neutral-first) so theming later is a token swap.

## Phase 2 — combat tracker (the index-card shuffle)
- [ ] Add combatants (PCs + monsters) to one encounter
- [ ] Initiative entry/roll + auto-sort; turn cycling with round counter
- [ ] Delay / ready (pull out and reinsert)
- [ ] HP damage/heal, temp HP absorption; PF1e dying rules (disabled/dying/stable,
      death at −Con) — keep per-system, not 5e death saves
- [ ] Effect durations as a rounds-remaining counter
- [ ] Glanceable creature card reusing the Phase-1 sheet components for monsters/NPCs

## Phase 3 — creature & encounter library
- [ ] Reusable statblocks; build encounters ahead of time and drop into the tracker

## Phase 4 — campaigns, multiplayer & sync
- [ ] GM campaigns, invite players, attach characters, live sync (accounts + backend)
- [ ] Push notifications (turn / damage / conditions / GM edits / chat) with per-category
      toggles and a push-primer

## Phase 5 — marketplace, creators & the "magic"
- [ ] Modules with pre-populated, combat-ready encounters & treasure
- [ ] GM-gated treasure discovery (in-app gesture notifies the GM; no serial numbers)
- [ ] Campaign chat with per-language ciphers (the "Elvish" trick) + GM whispers
- [ ] Build-your-own campaign
- [ ] Marketplace: sale cut + usage royalties; subscriptions (player sync, GM per-campaign)

## Post-1.0
- [ ] Avatar editor (composed from app-provided/marketplace assets; no user uploads)
- [ ] Other game systems (PF2e, D&D versions) as separate versions/apps, not one engine
- [ ] VTT interoperability via export (e.g. Foundry), not building a VTT
