# Bone Jarring Game System — Vision

> Working title: **Bone Jarring Game System** (lineage: the @bonejarring Tumblr, the #BoneJarring
> tag on the original 2013 post, and the "Bone Jarring" logo splash already in the SwiftUI repo).

> A native Apple-ecosystem toolset for running tabletop RPGs, starting with a combat
> tracker usable on an iPad while standing at the battle mat.
> System focus: **Pathfinder 1e** first.
>
> Status: OUTLINE — fill in `[YOU FILL IN]` sections, cut/rearrange freely.
> Last updated: 2026-06-28

---

## 1. North Star (one sentence)

The thing the whole product is in service of (decided):

> *Surface the right fiddly-bits at the right moment, so the gamer is never buried in
> paperwork or page-flipping in the heat of the game.*

Note: "gamer" (not just "GM") is deliberate — the pain belongs to everyone at the table, even
though the GM remains the platform's center of gravity (see Framing below).

### Framing & constraints (decided)
- **GM is the center of gravity.** Players and creators orbit the GM's at-the-table experience.
- **Dual success, one path.** Primary: "a real product." Acceptable: "I finally have the tool
  I always wanted." These are not a fork — the personal tool is the on-ramp to the product.
- **Resource reality.** Unlikely to build all of this solo in one lifetime; funding/hiring/AI
  help is possible but not assumed. Therefore:
- **Hard rule — every phase ships as a finished, satisfying thing on its own.** No phase may
  depend on a later phase to be worth using. Build plumbing only when the phase that needs it
  arrives. The first slice must deliver the personal win standalone *and* be the credible demo
  that could attract help/funding.

---

## 2. Origin & guiding principle

- The 50-year problem: some GMs improvise statblocks from memory; the rest of us drown
  in lookups and paperwork mid-combat.
- Prior attempts: index cards → FileMaker Pro database → printed cards in a tabbed drawer
  (serial numbers per creature/item, initiative cards, spell-duration cards in the shuffle).
- What worked about the card system, to preserve:
  1. **Combat tracking** — the index-card shuffle (initiative order, delays turned sideways,
     spell-duration cards reinserted at the right count). → now Phase 2 combat tracker + combat mode.
  2. **Items that had secrets** — a treasure card showed a player-facing description + a serial
     number (e.g. TEM1761), but the *real* properties were the GM's, revealed by the rules over
     time. GM-gated discovery. → this is the Phase 5 "hand a treasure with a swipe; discover its
     properties by the rules" magic, tracing straight back to the cards. A signature differentiator.
- What killed prior attempts: the **data-entry mountain** (hours typing in modules) + scope.

### Guiding principles (decided)
Operational translations of the North Star — testable against any screen:
1. **Right information at the right time.**
2. **Common tasks are one tap away.**
3. **The system helps gamers keep their place.**
4. **Most relevant information is glanceable.**

---

## 3. Participants & roles

The product is multi-participant from the ground up. Roles:

### Game Master
The central role. A GM owns one or more **campaigns**. Within a campaign they can:
- Author or **buy** content: encounter areas, NPCs, campaign flavor (history, geography,
  deities, etc.).
- **Invite players** to the campaign.
- **See players' characters** and make changes to them.
- Run **combat mode** (initiative tracker; any on-screen map is far-future/optional and still
  not a VTT — see Positioning & non-goals).

### Player
- Owns their character(s) and has a **fully functional character sheet**.
- **Two modes for a character:**
  - **Standalone** (not attached to a campaign): **fully offline** (the bundled PF1e ruleset makes
    even leveling/item acquisition work without connectivity — see §4 opportunity).
  - **Campaign-attached**: everything synced and live with the GM's campaign — **requires online**.
- Joins a campaign by invitation.
- **Editability is contextual (decided):**
  - **Standalone (non-campaign):** the player can edit **anything**, on **any device** the app
    runs on. Full control of their own character.
  - **Campaign-attached:** **many things become GM-editable only** — edit authority shifts to the
    GM (e.g. progression, awards, conditions); the player keeps some (notes/biography, moment-to-
    moment use). `[refine the exact field-level permission map later]`
  - Authority is therefore unambiguous at any moment → resolves the earlier silent-edit + sync-
    conflict concerns. Detaching restores full self-edit (portability).
- **Avatar designer**: make and/or buy custom assets to customize ("trick out") characters.

### Content creator / publisher
- Makes and sells **campaigns, modules, characters, or custom assets** through a built-in store.
- Two revenue mechanics:
  - **Sale cut**: platform takes a percentage of each sale.
  - **Usage royalty** (the novel part): creators earn whenever their asset is *in use* in an
    online campaign — tracked via time players spend in encounter areas, when they meet a sold
    character, when a sold item is used, etc.
- See §11 for the marketplace/monetization model and its dependencies.

Table style (confirmed): physical battle mat + minis, GM moving around the table holding an
iPad. (This drives the combat UI — and the whole in-person, not-a-VTT positioning.)

---

## 4. Platform & technology principles

- **Native**, not web/VTT. Apple ecosystem. Platform priority differs by product (decided):
  - **Character sheet:** iPhone → iPad → Mac (players carry phones).
  - **Combat tracker:** iPad → Mac, **no iPhone** (too small to run a fight from while at the mat).
  - **Apple Watch:** player-side combat companion (later phase). Deliberately minimal — two states:
    - **Out of combat:** character **name + avatar** and a **"Roll initiative"** button (enters
      combat mode — same hinge as the phone; feeds the GM tracker in attached mode).
    - **In combat:** **HP** (adjust via **Digital Crown**) and one button to **roll a single
      attack with the primary weapon**.
    - Everything else requires the phone. Pairs over WatchConnectivity (companion to the phone's
      combat mode); HP changes flow phone → GM tracker in attached mode. *Data-model note:*
      requires a designated **primary weapon** flag on a character — add early.
- Stack (confirmed): SwiftUI + SwiftData; CloudKit/iCloud for personal sync. Builder is
  comfortable with the whole stack **except CloudKit** (not used yet) — so CloudKit is the lone
  learning curve and the main early technical risk. Mitigation: design the SwiftData schema
  CloudKit-legal from day one (see engineering principles) and **spike CloudKit early** rather
  than discover it late.
- **OS version policy (decided): fluid — current OS or next-version beta only.** No backward
  compat; use newest APIs immediately (SwiftData, latest SwiftUI, Foundation Models, CloudKit) with
  no `#available` overhead. Cost: smaller addressable audience (latest OS + capable hardware) —
  acceptable for a passion-first/niche tool, and consistent with the AI feature's hardware needs.
  Revisit only if broad commercial reach becomes the goal.
  - **Caveat — this is cheap only pre-launch.** With no users yet, latest-only costs nothing.
    *Once shipped, every min-OS bump can strand existing (and eventually paying) users* — so the
    policy hardens into a real commitment at ship. Revisit it deliberately at launch, not by habit.
- **Glanceable while standing/moving**: large touch targets, high contrast, readable at arm's
  length, one-handed operation, minimal precise dragging.
- Sync across your own devices is a convenience, not a dependency.
- **Core principle — local-first for standalone; campaign mode requires online (clarified):**
  - **Standalone** (not in a campaign): **fully offline** — character sheet and a GM's own
    unshared combat tracker work with no connectivity.
  - **Campaign-attached:** **basically requires online access** — it's live shared state across
    people. Offline-campaign workarounds may be possible but are **not a priority**.
    - *Candidate workaround:* since play is in-person, devices in the room could talk **peer-to-peer**
      (Apple's **Multipeer Connectivity**, local Wi-Fi/Bluetooth, no internet/server, GM iPad as hub).
      Fits the in-person model well — but it's finicky (reliability, reconnection, group size) and a
      second transport to maintain alongside cloud sync. Low expectations; explore later.
- **Works at the table**: *standalone* use is fully usable offline with no login (character sheet,
  a GM's own unshared combat tracker). *Campaign* play is online and requires being in the campaign
  (per the standalone-vs-campaign split above).
  - So sync is an overlay you opt into by joining a campaign; opting in brings a connectivity
    requirement with it. (Pattern repeats across roles.)
- **Opportunity**: Pathfinder 1e rules are open (OGL). Bundling the ruleset locally would let
  leveling/magic-item acquisition work offline too — reserving the internet purely for
  campaign sync + marketplace, not core rules. `[DECISION]`

### Design north star — accessibility-first, grounded in the builder
The builder is color-blind, ADHD, and uses reading glasses, and finds **basic, low-clutter GUIs
the most usable**. This is the guiding aesthetic, not a constraint to work around — and it's a
strategic edge (most TTRPG tools are dense and color-heavy; a calm, legible, color-safe one is a
real niche). It also doubles as universal design that benefits everyone.
- **Never encode meaning by color alone** (color-blind): every signal pairs color with text,
  icon, shape, or position. Hard rule, not a habit.
- **Calm + low cognitive load** (ADHD): one clear focus, minimal motion, show-less-by-default.
  This is *why* glance-then-drill-down is right — and it's already in the design.
- **Generous legibility** (presbyopia): large default type, real Dynamic Type support.
- **Theme via a semantic token layer, neutral-first** ("do it right and theming gets easy"):
  route every color/style through semantic tokens (start with Apple's semantic colors), so the
  calm neutral default is just the baseline theme. Richer theming — and possible **user-custom
  theming** later — becomes a swap of the token set, not a rewrite. `[future feature]`

### Design & engineering principles (decided — bake in from commit one)
- **Native Apple styling, as default as possible.** Lean on stock SwiftUI components, semantic
  system colors, SF Symbols, standard controls, and native sheets/detents. (The visualize
  mockups are layout/flow sketches, not the visual target — the real app should look like a
  stock Apple app, which also gets us dark mode + Dynamic Type largely for free.)
- **Dark mode** from the start — guaranteed by using semantic colors, never hardcoded ones.
- **Everything scrolls** — `ScrollView`/`List` content between any fixed chrome (header, action
  bar, tab bar), respecting safe areas.
- **Dynamic Type** — use system text styles, no fixed point sizes. *Implication:* dense rows
  (the 6-ability grid, AC/touch/flat row, 4-button action bar) MUST reflow at large accessibility
  sizes — use `ViewThatFits`/adaptive stacks, not fixed grids. This is a real design constraint.
- **Localizable (i18n)** — String Catalogs, no string concatenation, locale-aware number/dice
  formatting. **Two distinct jobs, don't conflate:**
  - **UI/chrome** (your own labels/buttons) — cheap, any language via String Catalogs (Hindi fine).
  - **Rules content** (spell/feat/class text) — hard. Official PF1e translations exist only for a
    few European languages (Spanish, German, French, Italian) and are *licensed publisher IP*, not
    open/bundleable; the open SRD is **English-only**; **no Hindi** edition exists. So a non-English
    version is realistically a localized *interface* over *English rules text* until content
    localization is licensed or translated (a big, separate effort).
  - **Decision:** ship **English-only for now**, but keep i18n foundations in the code from day one
    (so UI localization later = adding a translation file, not a refactor). Localize the **UI** later
    if there's demand; do **fully-localized** versions only if licensable content translations
    become available. English-only *product*, i18n-ready *engineering*.
- **Right-to-left (RTL) support** — explicit first-class requirement (Arabic, Hebrew). The whole
  layout mirrors: the upper-*right* avatar moves to upper-left, drill-in chevrons flip, navigation
  reverses. Get it mostly free by using **leading/trailing** semantics everywhere (never left/right)
  and letting directional SF Symbols auto-mirror. Test with the RTL pseudolanguage early.
- **Accessibility (a11y)** — VoiceOver labels, ≥44pt hit targets, contrast.
- **CloudKit-compatible schema from day one** — if personal iCloud sync is on the roadmap (§11),
  design the Phase-1 SwiftData model within CloudKit's rules (defaults/optionals, no unique
  constraints, optional relationships). Cheap now, painful to retrofit.
- **Priority:** a11y + full i18n content can mature in later versions, but the *foundations*
  (semantic colors, text styles, String Catalogs, reflowing layouts) go in **as early as
  possible** — they're cheap up front, expensive to retrofit.

---

## 4a. Systems & licensing (architectural pillar)

**Focus now: Pathfinder 1e only.** A system-agnostic core is an *aspiration, not a current
mandate* — do not build a multi-system engine now. **PF2e support will be a new version of the app
or a separate app altogether**, not necessarily a rules module in one engine (PF2e is a major
redesign — three-action economy, different math — so a shared engine is genuinely hard and likely
not worth forcing). **The various D&D versions (5e 2014, 5e 2024, etc.) follow the same rule:** each
would be a new version or a separate app, not a module in a unified engine. Build PF1e well; just
don't make multi-system *impossible* later.

**All three are legally buildable from open content — no contract with any publisher needed:**
- **Pathfinder 1e / 2e (Paizo):** OGL + the newer ORC license. Nearly the *entire* ruleset is
  open content (cf. Archives of Nethys). This is the MOST open system — least friction.
- **D&D 5e (Wizards):** SRD v5.1 and v5.2.1 are under **Creative Commons CC-BY-4.0**, and it is
  **irrevocable** (made so after the 2023 OGL backlash). Commercial use allowed with a one-line
  attribution. No contract, no royalty, no permission.

**The catches for 5e (scope, not permission):**
- SRD is a *subset* — core engine only, not every subclass/spell/monster, not named settings.
  Can include SRD content; cannot include book-only content or let users import purchased content.
- Cannot use D&D trademarks/branding, and cannot even claim "compatible with D&D." Ship under your
  own brand using the mechanics (rules/mechanics themselves aren't copyrightable; expression is).
- Net: 5e is buildable but gives a *smaller* usable rules slice than Pathfinder.

**Caveat:** building on open content yourself = solid ground. A marketplace where third parties
sell content raises sharper IP questions — see §11 content policy. (Not legal advice.)

### Content extensibility — a FUTURE feature (do not let it hamstring now)
Eventually the app should **adapt to new content** — new Paizo releases, homebrew, etc. — which
points toward rules-as-data rather than hardcoded logic. **But this is explicitly a future feature,
not a Phase-1 build.** We don't need the answers now (content-definition format, versioning,
provenance, override/stacking) and should NOT pay to build that pipeline today.
- **Stance:** don't make extensibility *really hard* later, but don't engineer for it now. In
  practice that's just light hygiene — keep PF1e rules data reasonably separable from UI so it's
  not impossible to swap/extend later. No content-pack pipeline required in Phase 1.
- The `creatures` d20→Pathfinder abstraction is a *nice-to-have* head start here, not a mandate.

---

## 5. Product scope — phased (build small, add on)

Ordered so each phase is a finished, satisfying thing on its own (see §1 hard rule).
Sequencing philosophy: **foundation-first** — build the reusable character core, then expand
outward into combat and the campaign/platform layers.

### Phase 1 — Standalone character sheet (Pathfinder 1e) ← START HERE
The foundation everything else reuses, and the credible "demonstrates the possible" demo.
Standalone, offline, no accounts. Monetization path: free version → later in-app purchases +
accounts. Detailed in §5a.
- **One creation wizard, transcribe flavor first** (the "real dumb" MVP, your 2013 words):
  transcription isn't a separate path — it's the wizard flavor that trusts direct input and needs
  almost no rules engine, so it ships first. The guided/rules-driven flavor (and leveling) fills
  in as the rules engine matures. See §5a.
- Reason it's first: combat mode, the GM's view of player characters, and campaign attachment
  all sit on top of the character data model. Build it once, reuse everywhere.

### Phase 2 — Combat tracker (the index-card shuffle)
Initiative + turn cycling + HP/conditions + spell durations, reusing the Phase-1 character
model. Detailed in §6.

### Phase 3 — Creature & encounter library
Reusable statblocks; build an encounter ahead of time, drop it into the tracker. Not yet specified.

### Phase 4 — Campaigns, multiplayer & sync
GM campaigns, invite players, attach characters, live sync. First phase that needs accounts +
backend. Not yet specified.
- **Push notifications (campaign-attached only):** alert a player when **it's their turn** or
  **something happens to their character** (damage, condition, GM edit). Justification: players
  switch apps mid-session; this pulls attention back.
  - "It's your turn" is the *same event* that auto-flips the phone into combat mode — push +
    deep-link into the combat HUD are one mechanism.
  - **Per-category toggles** (turn / damage / conditions / GM edits / chat) — don't notify by
    default on everything; over-notifying is an attention tax (esp. given the ADHD lens).
  - Requires APNs + backend (device tokens, send service) — only possible once sync exists.
  - **Push-primer** needed before the iOS permission prompt (permission is one-shot; denial is
    sticky). Not Phase 1.
  - **De-risked:** builder shipped this full stack — push, primer, and per-category notification
    preferences — in **Indeed Job Search (2023)**. Lift the proven patterns; not speculative work.

### Phase 5 — Marketplace, creators & the "magic" (the original dream)
The parts nobody has solved well:
- Publish/import modules with **pre-populated, combat-ready** encounters & treasure.
- Hand a player a treasure "with a swipe"; they discover its properties by the rules. **No serial
  numbers** (the old FileMaker lookup workaround) — to ask about an item, the player does an in-app
  **gesture on it to notify the GM**, who controls the reveal.
- **Campaign chat with multiple game languages** (= the 2013 "Elvish" trick, realized):
  tag a message with a language; characters who **know** it (per their character's known-languages
  data) see plaintext, those who don't see it **garbled**. GM sees all.
  - Garble each language with a *consistent per-language cipher* (not random noise) so players can
    recognize "that's Elvish" without understanding it — the real in-fiction experience.
  - Same channel delivers private GM→player **whispers** (the 2013 "type a message to a player").
  - Depends on real-time chat infra (campaign/sync layer); reuses character known-languages data.
- Build-your-own campaign.

Prioritization within Phase 5: Not yet specified.

### Post-1.0 features (beyond the roadmap above)
Explicitly after 1.0 ships — captured so they're not lost, not scoped now.
- **Avatar editor** — the player avatar designer: compose characters from **app-provided or
  marketplace assets** (create/buy), not photos. Involves an asset pipeline + rendering; ties into
  the marketplace.
  - **No user-uploaded images** — out of scope now, and **possibly never**. Uploads drag in
    content moderation (incl. legal CSAM-scanning duties), hosting, and abuse handling; avoiding
    them keeps avatars curated, safe, and cheap. Avatars = composed from vetted assets only.
  - **Avatar thumbnail in the sheet header** (upper-right, tap → Biography/avatar) arrives with
    this feature. Until then there is **no avatar element** in the header — no placeholder icon.
- **Supporting other game systems** — PF2e and the D&D versions, each as a **new version or a
  separate app**, not a module in a unified engine (per §4a).
- (room for more)

### Positioning & explicit non-goals (decided)
**These are aids for IN-PERSON tabletop play, NOT a virtual tabletop (VTT).** The physical table
is the battle map; the minis are the tokens. This is a *scope-slashing* decision, not a limitation:
- **Out of scope:** online/virtual maps, grids, fog of war, on-screen token movement, video chat —
  the heavyweight infrastructure that makes Roll20/Foundry huge. Not your problem.
- **Why it's a strategic edge:** the incumbents are VTT-centric, built for *remote* play; the gap
  the landscape research found is the people around a *real* table. You serve that table.
- Also out (at first): no multi-system on day one (PF1e first).
- Note: an on-screen map display, if ever built, is far-future/optional and still **not a VTT** —
  the physical mat remains the design center.

**VTT strategy — integrate, don't build (the online dimension).** The way to reach online play is
to plug into an existing virtual tabletop rather than build one. Two layers:
- *Aspirational — formal partnership* (Roll20 / D&D Beyond): a **longshot**. Partnerships favor
  leverage (users/revenue) a pre-launch solo project lacks; D&D Beyond is a system mismatch (D&D,
  Hasbro-owned) with no open public API historically; Roll20 at least supports PF1e + has a scripting
  API. Any such tie-in is **platform risk** (they can close the door — cf. the OGL episode).
- *Pragmatic — interoperability via import/export* (the realistic path to the same goal): export a
  Bone Jarring character to a format a VTT can ingest, the way **Pathbuilder exports into Foundry**.
  Needs no one's permission, and fits the "your character travels with you" portability theme.
  **Foundry** is the friendliest target (open, self-hosted, modules) vs. the walled gardens.

---

## 5a. Phase 1 in detail — the standalone character sheet (THE FIRST BUILD)

The foundation. Two surfaces: the **character sheet** (view/use) and the **creation wizard**
(build/edit). Sequenced so something usable ships early.

**The character sheet — v1 scope: a "basic combatant" (decided)**
The first sheet has **everything needed for basic combat and nothing more.**
- **In v1:** ability scores + modifiers, HP (current/max/temp), AC (normal/touch/flat-footed),
  saving throws, weapons/attacks (to-hit + damage, BAB, CMB/CMD), initiative, speed, notes.
  - *Weapons are entered as **attack lines** (name, to-hit, damage) — not managed gear items. AC is
    a typed value, not derived from equipped armor. Consistent with the transcribe-only v1.*
- **Explicitly NOT in v1:** skills, spells, conditions, and the entire **equipment / inventory
  system** (which subsumes encumbrance — carrying capacity, load penalties, armor-as-items).
  Each is a sprawling or fiddly subsystem deferred to later increments. This is enough to run a
  martial character through a fight.
- Glanceable layout (§5c); works fully offline; saved locally.

**Creation in Phase 1 — the transcribe flavor only**
The creation wizard is one framework with multiple per-step "flavors" (your Abilities step already
shows this: classic / dice pool / heroic / purchase / standard *and* transcribe). **Phase 1 builds
only the transcribe flavor** over the v1 basic-combat fields: build/manage a character by entering
values directly — trusts input, minimal validation, needs almost no rules engine.
- Build on the existing `adventurers` scaffold (Abilities done; other tabs stubs; archived "Old Wizard").
- UX (a11y/ADHD north star): save-and-resume, clear progress, "you can change this later," escape hatches.
- The guided/rules-driven flavor, leveling, and AI-assist are **not Phase 1** — see §5a-cont.

**Competitive reality (verified 2026-06-28):** PF1e character sheets are NOT an open field.
Existing native iOS/iPad apps include **PathCompanion** (PF1e-specific, dynamic stat updates,
multiclass support, *already has multiplayer campaign support*), **RPG Scribe** (PF1e + 3.5,
full auto-math), and **PrismScroll**. Implications:
- The sheet is the right *foundation*, but it is NOT a differentiator or funding demo on its own —
  it's a late entrant in a solved category. Differentiation must come from the larger vision
  (combat-at-the-mat, GM platform, usage royalties), not the sheet.
- Action: study PathCompanion closely — it's both the closest competitor AND proof the PF1e data
  model is buildable. Match table stakes; find the 1–2 things it does poorly that point at your
  vision. `[TODO before committing Phase 1 scope]`

Open decisions for Phase 1:
- Free vs. paid boundary (decided per §11): the standalone character sheet is **free** on a single
  device; **cross-device sync is the minimal player subscription**. (GM per-campaign sub is a later
  phase.)
- PF1e data: for the **first deliverable, hand-enter the basics** (the transcribe-only v1 needs
  almost no reference data anyway). Beyond that — hand-enter vs. ingest an open dataset (PCGen/SRD)
  — is **genuinely open / TBD**; it only needs answering when the **guided wizard** requires the
  full rules corpus.

What Phase 1 deliberately does NOT do: no skills, spells, or conditions; no guided/rules-driven
creation or leveling; no AI-assist; no print/PDF; no accounts, sync, campaigns, or combat tracker.
(All of these are needed to ship eventually — see §5a-cont.)

---

## 5a-cont. Needed to ship, but NOT Phase 1 (completing the character sheet)

These complete the character-sheet product and are needed before it's truly "shippable," but they
come **after** the Phase-1 basic-combatant sheet works. Internal order TBD.

- **Skills, spells, conditions, and the equipment/inventory system** (incl. encumbrance,
  armor-as-items) — the subsystems deferred from v1. Each is a real build (PF1e spellcasting
  especially).
- **Guided / rules-driven wizard flavor + leveling** — walks ability scores → race → class →
  skills → feats → gear → spells, validating and computing as it goes (reuse the `creatures`
  Transactions/bonus engine). Needs the PF1e rules content + calc engine. Same wizard framework as
  the Phase-1 transcribe flavor; flavors can mix per step. Keep rules data reasonably separable from
  UI (light hygiene per §4a) — no content-pack pipeline now.
- **AI-assisted flavor (Apple Intelligence / Foundation Models)** — at the Biography step, a
  "help me" affordance drafts **names, appearance, backstory** from race/class/alignment; player
  edits and accepts.
  - **Hard division:** AI assists only *narrative/subjective* content; never mechanics (anything
    with a correct answer stays in the deterministic rules engine).
  - **On-device** via Foundation Models: private, free, offline, no backend. Needs **graceful
    fallback** on non-Apple-Intelligence hardware (hide it; manual entry still works).
  - **Cultural line:** AI for a player's *private* prep is accepted; AI in *marketplace* content is
    contentious (ENnies banned AI submissions). Text only for now; AI *image* gen is separate/fraught.
- **Print / PDF export — a pleasing paper sheet.** Fits the in-person philosophy and closes the loop
  with the FileMaker printed cards. A *separate paper-optimized layout* (denser, multi-column, fixed
  page) — another rendering of the same `Creature` data. Native iOS print/PDF; the work is the
  layout. Also serves legibility. Extends later to printing **combatant cards for the GM**
  (regenerate the index-card drawer on demand).

---

## 5b. Prior art — your two existing codebases (examined 2026-06-28)

You have two prior attempts. They are **complementary, not redundant** — one holds the hard
thinking, the other holds the right architecture.

### `creatures` (UIKit, 203 commits) — the domain-model quarry
Where the real IP lives. Notable:
- **A d20 → Pathfinder abstraction already exists in code**: `d20Ability.swift`, `d20Bonus.swift`,
  `PathfinderAbility.swift`. This is the system-agnostic-core pillar (§4a) *already realized* —
  a generic d20 base specialized for Pathfinder.
- **A Transactions engine** (`Transaction`, `TransactionsController`, `TransactionsProtocol`) —
  models changes/bonuses as transactions. This is the foundation for rules-correct bonus stacking
  and undo. Hard to design; you already did it.
- Dice/rolling utils (`Dice`, `Rolls3d6`, `Rolls4d6`), Core Data model with heavy migration history
  (6 schema versions = real iteration), iOS **and** Mac targets.
- The original `Creatures.fmp12` FileMaker DB is committed — the source-of-truth lineage.
- Downside: UIKit + storyboards = legacy UI tech; not the future-facing front end.

### `adventurers-and-protagonists` (SwiftUI, 79 commits) — the right architecture, thinner
- Modern **SwiftUI + SwiftData**, cross-platform with explicit `IOSBrowser` + `MacBrowser`.
  This is the correct local-first, multi-device foundation going forward.
- Character-creation **wizard** scaffold: the **Abilities** tab is fleshed out (5 generation
  methods: Classic/DicePool/Heroic/Purchase/Standard) and includes a **Transcribe** path —
  i.e. *enter an existing character*, which maps exactly to the Phase-1 "real dumb" MVP.
- Other tabs (Class, Combat, Equipment, Feats, Race, Skills, Spells) are **stubs** (~280 bytes).
- Already **BSD-3-Clause licensed** (open-source-ready).
- Downside: thin domain model (`Ability`, `Adventurer`, `Proto`); most logic not yet built.

### Repo & licensing decision (decided)
**Public + BSD** (continue current). Rationale: the code isn't the moat (commoditized category;
the moat is the integrated platform, the Bone Jarring brand, and execution), openness aids
credibility and attracting collaborators/funding, and it suits a long-held passion project.
Note: GitHub private repos are actually *free* for solo devs — so this was a strategy choice, not
a cost one. BSD doesn't transfer copyright: as sole author you can dual-license or build any truly
differentiating component commercially later. (Separate from game-content licensing in §4a.)
- **Refinement (per-phase):** the **character sheet stays public + BSD** (the foundation, the
  commoditized part, the credibility piece). The **combat tracker and later phases may go private**
  when built — that's where the differentiating platform value concentrates. Sensible hybrid:
  open foundation, protected platform.

### Recommendation (CONFIRMED)
**Continue on `adventurers-and-protagonists` (SwiftUI/SwiftData), and port the proven domain
model from `creatures` into it** — specifically the d20→Pathfinder ability abstraction and the
Transactions/bonus-stacking engine. Don't re-architect the hard parts; translate them. The
"Transcribe existing character" path is the fastest route to a usable Phase-1 build.
`[YOU CONFIRM / OVERRIDE]`

---

## 5c. Character-sheet GUI & interaction model (decided)

Worked out via iPhone mockups; applies phone-first, adapts up to iPad/Mac.

### Structure: dashboard of cards + tab bar
- The main screen is a **dashboard of condensed cards** (ability block, combat block,
  conditions, condensed skills, condensed spells, etc.).
- **Rule: each card = the compressed view of exactly one tab.** No orphan cards.
- iPhone tab bar consolidated to **5**: Overview · Combat · Skills · Spells · More.
  (Biography+avatar, Equipment, Journal live under **More** — low mid-game frequency.)

### Three interaction layers
1. **Card** — glance + **tap-to-adjust in place** (HP −/+ steppers, condition toggles).
2. **Tab** — the expanded working view of that domain.
3. **Modal sheet** — full reading of one item (a spell/feat/item), as a **bottom-up sheet
   with detents** (half-height peek → flick to full). iPhone idiom.

### Tap disambiguation (must be visually distinct)
- Adjuster control → acts in place. Card body → opens its tab. Item row → opens detail modal.

### Two modes: Manage vs Combat
- **Manage** (default): the dashboard above, for browsing/editing the character.
- **Combat mode** (decided: a *distinct mode*, not just a tab): a focused state that **takes
  over the screen** during a fight. A play-optimized HUD:
  - HP (−/+), defenses (AC/touch/flat-footed), **active effects with round counters**
    (mirrors the GM combat tracker's spell durations — same data, player side).
  - Attacks (to-hit/damage, roll affordance), **class resources as spend-counters**
    (Smite pips, Lay on Hands uses, spell slots).
  - **Action bar — the "take your turn" surface:** buttons for **Attack · Cast · Use item ·
    Use skill** (plus room for Feat/Ability/Other). Each opens a focused picker (your spells /
    usable items / skills) as a bottom sheet → choose → execute.
  - **Loop closure with the 2013 vision:** casting a duration spell spends the slot AND
    auto-creates a tracked **active effect with a round counter** in the HUD (= the old "write
    the spell+duration on a recycled card and shuffle it into initiative" trick, automated).
    "Use item" decrements the consumable and applies its effect the same way.
  - **Action economy (decided):** early combat mode just **exposes the action buttons** (optionally
    a quiet standard/move/swift *hint*); it does **not** track or enforce the full action economy.
    Full economy tracking (spending/graying-out standard/move/swift/free per turn) is a **later
    feature**.
  - **Entry — standalone:** a **"Roll initiative" button** enters combat mode (thematic and
    intuitive — rolling initiative *is* how a fight begins). The roll seeds the player's turn order.
  - **Entry — campaign-attached:** **auto-triggered by the GM over sync** (GM starts encounter →
    player phones flip to combat mode; GM drives the round/turn banner). Likely prompts each
    player to roll initiative, feeding the GM's tracker. ← concrete instance of local-first + sync.
  - **Exit:** combat ends (GM ends encounter, or manual "End combat" standalone).

### Cross-platform adaptation
- Cards and detail views are **self-contained, reflowing SwiftUI components**; only the layout
  shell changes: iPhone 1-column + bottom sheets → iPad/Mac multi-column + popover/inspector
  panes (detail is NOT a bottom sheet on iPad/Mac).
- **Print / PDF is another such shell.** The pleasing paper layout (§5a-cont) is just one more
  target for the same reflowing components (fixed page, multi-column). So those components are a
  prerequisite for print — building them right for cross-device adaptation is what makes a good
  printout possible.

---

## 6. Phase 2 in detail — the combat tracker

Reuses the Phase-1 character model. What it must do to replace the card drawer:

- **Add combatants**: PCs and monsters into a single encounter.
- **Initiative**: roll or enter, with modifier; auto-sort the order.
- **Turn cycling**: clear "whose turn" indicator; next/previous; round counter.
- **Delay / ready actions**: pull a combatant out, reinsert at the right spot later
  (the "turn the card sideways" move).
- **HP tracking**: damage / heal, current vs. max, **temporary HP** (separate pool, absorbed
  before real HP, doesn't stack — take the higher).
- **Dying state — PF1e model (NOT 5e death saves).** Death saving throws are a *D&D 5e* mechanic
  and don't apply here. Track the PF1e dying system: *disabled* at 0 HP; *dying* + unconscious
  below 0 (lose 1 HP/round, bleeding out); **death at −Constitution score**; per-round
  **stabilization** via a Constitution check (DC 10 + current negative HP) or external Heal/magic.
  (5e death saves would only return if a future 5e version is built — keep this logic per-system,
  §4a.)
- **Conditions**: mark status effects per combatant.
- **Spell/effect durations as a rounds-remaining counter** (not slotted into the initiative order).
  Reality check: nobody tracks expiry on the exact initiative count — durations tick down and
  expire on the character's turn. So the model is simply a per-effect **rounds-left** count that
  decrements each round; **showing "N rounds left" is the useful part.** (Simpler than the old
  "spell card reinserted at the right count" trick — and how people actually play.)
- **Glanceable creature card**: AC, key saves, attacks, special abilities — the "card front."
- Scratch notes per combatant. `[YOU FILL IN: anything else from the old cards]`

**Monster stat blocks crib from the character sheet (key reuse).** A monster/NPC is the same
underlying `Creature` as a PC, so its tracker stat block reuses the Phase-1 character-sheet data
model AND its glanceable card components — not a new screen. (This unified model is *named intent*,
not hindsight: the repos are deliberately called `creatures` — the base type — and
`adventurers-and-protagonists` — PCs and the wider cast as the same thing. The lineage runs all
the way back to the original FileMaker database, also named **Creatures** (`Creatures.fmp12`,
committed in the repo): three implementations across decades, one core idea, one name.)
- *Dividend:* foundation-first pays off — Phase-1 sheet work yields Phase-2 monster stat blocks
  largely for free.
- *GM doesn't get lost:* one consistent layout for every combatant (PC or monster) means the GM
  reads them all the same way and the thing they reach for is always in the same place. Directly
  serves guiding principle #3 ("keep their place") and the calm/low-load accessibility north star.

What the v1 sheet deliberately does NOT do: no skills, no spells, no conditions (all deferred to
later increments); no accounts, no sync, no campaigns. `[YOU FILL IN: anything else to exclude]`

Hardest UI question to settle: how the active turn + initiative list stay readable and
operable at arm's length while you walk the table. `[design exploration to come]`

---

## 7. Data model (Pathfinder 1e) — first pass

Core entities to represent. Rough list, refine later:

- **Combatant** (instance in an encounter): name, side (PC/ally/enemy), initiative roll,
  init modifier, current HP, max HP, AC (normal/touch/flat-footed), conditions[], notes,
  link to statblock, current-turn flag, delayed flag.
- **Statblock / Creature**: the reusable definition (the card front data).
- **Effect/Duration**: source, name, **remaining rounds** (decrements per round; expires on the
  character's turn — no precise initiative-count tracking).
- **Encounter**: ordered set of combatants + round counter.
- **No serial numbers.** The FileMaker TEM1761 scheme was a paper workaround for linking. Items are
  identified objects in the system; when a player wants to know about an item, they do an **in-app
  gesture on it to notify the GM**, who handles the reveal. (Replaces serial-number lookup; the
  secret-item discovery mechanic, §5 Phase 5 — campaign-attached.)

Campaign-level entities (the platform layer):

- **Campaign**: owned by a GM; contains encounter areas, NPCs, flavor, invited players,
  player characters, and a content/marketplace origin (authored vs. bought).
- **Encounter area**: location with its encounters, NPCs, treasure (the module structure).
- **NPC**: campaign-scoped character (may reference a statblock).
- **Flavor / lore**: history, geography, deities, etc. Structured vs. freeform: to be determined.
- **Membership / invitation**: links players to a campaign with a role + permissions.

PF1e field specifics (full attack routines, CMB/CMD, saves, etc.) aren't enumerated separately
here: the combat tracker **shares the character app's panels/components**, so the correct fields
already come from the shared `Creature` model (per §6 reuse). Define them once in the character
sheet; the tracker inherits them.

---

## 8. At-the-table design principles

- Glance, don't read.
- Most-used actions (advance turn, apply damage) reachable with one thumb.
- No destructive action without easy undo (combat is chaotic).
- Readable in dim room lighting.

---

## 9. Why now / what changed since 2013 (context)

- Synced character sheets, leveling, basic combat tracking are now **solved & mostly free**
  (D&D Beyond, Pathfinder Nexus/Demiplane, Pathbuilder) — so the opportunity is the GM-side
  magic in Phase 4, not the bookkeeping.
- **Licensing got friendlier**: 5e SRD now under Creative Commons; Paizo's ORC license is
  open/perpetual. Building on this content legally is easier than ever.
- **AI** makes the old data-entry mountain — the thing that killed prior attempts —
  tractable for the first time.
- Caveat: the publishing scene is drawing hard lines on AI-generated content.

---

## 10. Open questions / decisions

1. ~~name / working title~~ → **Bone Jarring Game System** (working title, decided).
2. ~~Just for you, or for other GMs?~~ → Both; personal tool is the on-ramp to the product.
3. Pathfinder 1e data — hand-entered, or sourced from an existing dataset/SRD? `[OPEN]`
4. ~~How far into Phase 4 magic vs. personal tool?~~ → Build outward from combat; each ring
   finished before the next. Phase 4 is aspirational, not committed.
5. `[YOU FILL IN]`

---

## 11. Marketplace & monetization

### Revenue streams
1. **Sale cut** — percentage of each creator sale (campaigns, modules, characters, assets).
2. **Usage royalty** — creators earn when their content is *in use* in an online campaign;
   measured by time-in-encounter-area, sold-character encounters, sold-item usage, etc.
3. **Ads** — Not yet specified.
4. **Subscriptions (the core recurring model, decided):**
   - **Player sync subscription** — *minimal* charge for a player to **sync their standalone
     characters across their devices** (personal iCloud sync; SwiftData + CloudKit, Apple-hosted,
     no backend). Fair to paywall: local-first means single-device use stays free; you charge for
     cross-device convenience. Can ship far earlier than the campaign backend.
   - **GM per-campaign subscription** — the GM pays **per campaign**; **players in the campaign pay
     nothing extra**. A "healthy but not huge" charge — working figure **$8.99/month/campaign**
     (≪ $100). Rationale: GM-funded fits GM-as-center-of-gravity, and free players remove friction
     on the side that drives the network effect (more players → more GMs).
   - *Context to keep in mind (not blockers):* $8.99 **per campaign** is high vs. Roll20/D&D Beyond
     (~$5–10/month *total*) — defensible since the GM covers the whole table; App Store takes
     15–30% (net ≈ $6.50–7.60). A GM running several campaigns pays several times → a cap or
     "GM unlimited" tier is **deferred until users actually complain** (don't solve it speculatively).
     `[revisit pricing with data]`

### Dependencies & risks (so we sequence this right)
- **Usage royalty requires online play + telemetry.** It cannot work for offline/local sessions
  — those generate no usage data, so creators would get only the sale cut there. This monetization
  model is therefore *coupled to adoption of the campaign-sync layer.*
- **Telemetry = privacy surface.** Tracking how long players sit in an encounter area is detailed
  behavioral data; needs clear consent and transparency for GMs and players.
- **Royalty accounting is real infrastructure.** Per-use micro-payments need a usage ledger,
  attribution, and payouts — non-trivial to build and audit.
- **IP/licensing policy is mandatory.** Pathfinder 1e *mechanics* are open (OGL), so creators can
  sell rules-based content. But they cannot resell Paizo's proprietary IP (named settings, adventure
  paths, art). The store needs a content policy + moderation.
- **Two-sided market chicken-and-egg.** Need creators to attract GMs and GMs to attract creators;
  classic cold-start problem. Likely seed with your own content first.
- **Furthest from the MVP.** The entire marketplace presupposes accounts, sync, content formats,
  and a user base. It's a late phase, not an early one — but good to design the data model so it's
  *possible* later.
