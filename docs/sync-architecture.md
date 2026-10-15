# Sync Architecture — Directions & Rationale

> Status: **exploratory design notes**, not committed scope. None of this is needed for
> Phases 1–3 (standalone character sheet + combat + library are local-first/offline).
> Captured so the reasoning isn't lost when the sync/campaign phase (vision.md §4, §5
> Phase 4, §11) actually arrives. See `vision.md` for the product framing.
>
> Last updated: 2026-07-30

---

## 1. There are two different sync problems

They have different shapes; don't try to serve both with one transport.

1. **Personal cross-device sync** — one user's own characters across their Apple devices
   (iPhone/iPad/Mac/Watch). Single writer, conflicts rare, no other participants. This is
   the *player sync subscription* (vision §11): free single-device, paid cross-device.
2. **Campaign multiplayer** — a GM + players sharing live encounter/combat state. Many
   writers, real-time (turn hand-offs, HP flowing to the GM tracker, push), and **field-level
   authority** (GM-editable vs. player-editable when campaign-attached, vision §3).

Most of the pain in sync designs comes from treating one mechanism as the answer for both.

---

## 2. Decision: CloudKit first for personal sync; own the campaign backend later

- **Personal tier → CloudKit + SwiftData.** It's the narrow thing CloudKit is genuinely
  good at: zero backend, Apple-managed identity, offline queueing, native SwiftData
  integration, Watch-friendly. It's also the first monetizable sync feature, and needs no
  server. Turning it on is nearly a config flip (CloudKit container + the SwiftData
  configuration), which is why the schema has been kept **CloudKit-legal from day one**
  (all attributes optional/defaulted, optional relationships, no unique constraints).
  *Spike it early* — its surprises live in those schema rules.
- **Campaign tier → our own backend, later (Phase 4+).** Gated on there actually being
  campaigns/users. CloudKit is a poor fit here: Apple-only (forecloses web/Android), a weak
  query store (no joins, eventual consistency), no server-side compute, and opaque when it
  misbehaves. The marketplace, usage-royalty ledger, telemetry, and campaign chat all want a
  real database we control (Postgres — SQL is fine for the expected volume).

**Do not let CloudKit become the system of record for anything we'll need to query or
monetize.** Its honest sweet spot is the solo convenience tier.

---

## 3. Build vs. buy: own the semantics, rent the ops

The graveyard of turnkey sync products (see §6) plus CloudKit's ceiling argues for building
the campaign sync layer ourselves — but with a specific discipline.

**The durable, valuable thing is the *semantics* — the data model, sync protocol, and
oplog/cursor behavior — sitting on top of *commodity primitives*.** (This is the Indeed
lesson: they built their sync/backend logic on Mongo's raw read/write/replication + their own
queue; the primitives got swapped over years, the semantics survived every migration.)

Consequences:
- **The graveyard doesn't threaten us if we own the sync layer.** A deprecated product
  (e.g. Realm) is only fatal to those who coupled their *semantics* to a vendor's proprietary
  sync. Our semantics over boring Postgres → deprecations happen to other people.
- **Owning the interface converts vendor deprecation from an emergency into a migration we
  schedule.** Any future move (to a commercial sync engine, a different DB) becomes a
  swap-under-a-stable-boundary, with the homegrown system as a rock-solid fallback.
- **Drop the "own the datacenter / run the queue" half of the analogy.** That was forced in
  2004 (no managed cloud). For a solo project the tax that never ends is *ops*, not code:
  on-call, backups, patching, DDoS, and eventually marketplace-grade data-handling. So:
  **own the semantics, rent the ops** — managed Postgres (RDS/Neon/Supabase); you don't even
  need a real queue at first (Postgres *is* the oplog; `LISTEN/NOTIFY` or poll-on-sync is the
  wake; a real broker only when volume earns it). Keep the primitive count near one.
- **Guard the opportunity cost.** The moat is the at-the-table magic and the reveal/discovery
  mechanics, not the sync engine (vision §5b: "the code isn't the moat"). Build the thinnest
  sync layer that's ours and portable; resist gold-plating it.

---

## 4. The homegrown sync engine (shape, for when the campaign tier arrives)

A classic delta-sync / changes-feed design with per-scope cursors. This is, notably, what
CloudKit does internally (`CKServerChangeToken` + fetch-changes + tombstones + "token
expired → refetch"), so its semantics are a good reference to crib.

Clients keep a local replica in platform-appropriate storage (CoreData/SwiftData on Apple,
local storage on web, SQLite on non-Apple). A microservice serves sync by embedding the
last-synced watermark in a **sync token**; the server builds the response from it.

The four places this pattern lives or dies:

1. **What the token points at → a monotonic server sequence, not a timestamp.** One
   append-only oplog/changes table with a `bigserial seq`; token = last seq delivered; server
   returns `seq > token` up to a high-watermark captured at request start (so multi-page
   pulls stay stable under concurrent writes). Timestamps bite on clock skew and same-instant
   ties.
2. **Tombstones.** Deletes must travel as tombstone rows, or clients never learn to remove
   anything. Needs a retention window + a "your token predates our oldest tombstone → full
   resync" fallback. (The forgotten step → ghost rows forever.)
3. **Keep the token opaque.** Base64 a small struct (seq + scope + schema version). Clients
   never parse it, so its innards can change later without breaking them.
4. **The upload path.** Pushing local changes needs client-generated UUIDs (idempotent
   creates) + a client-op-id (retries don't double-apply) + a conflict rule. Our event-log
   instinct pays off here: append ops, server assigns seq, fold. It's also where field
   authority lives (server rejects a player writing a GM-only field) — which doubles as the
   royalty/audit trail.

**Message queue role:** pin its job. Clean split = **pull-by-token for state, queue-as-wake**
("something changed, come sync" → the vision's push notifications). If the queue is *also* the
write path, assign the oplog seq at the consumer, not the producer, or the "monotonic" cursor
isn't.

---

## 5. Scope = the campaign; participants see slices

The synced unit is the **entire campaign** (one seq space per campaign); each character/player
sees only their slice. So there's a cursor per `(campaign, participant)` over that one log.

- **Advance the cursor to the campaign's high-watermark, not to "rows I sent."** A player's
  token moves past events they weren't allowed to see; the server just omits those from the
  payload. Tracking received-rows instead leaks hidden events as gaps and makes the client
  loop re-asking.
- **Visibility isn't static — model a reveal as a new event.** When the GM reveals a
  treasure's real properties, whispers a player, or moves an NPC into view, something whose
  original seq is *behind* the player's cursor must reach them — and `seq > token` will never
  deliver it. So don't filter old rows; emit a **new event** ("grant P visibility of X", new
  seq) that flows the normal path. It must carry (or trigger a targeted re-send of) X's
  *current* state, because that client never saw X get created.

**This isn't extra machinery — it's the Phase 5 headline features falling out of the model:**
- GM-gated item discovery ("swipe a treasure, discover its properties by the rules", vision §5)
  and private GM→player whispers **are** reveal-events.
- The multi-language campaign chat cipher is the same shape: everyone gets the message event;
  your slice decides plaintext vs. garble. One log, projected per role.
- Read-projection (what you *see*) and write field-authority (what you may *change*) are
  mirrors, both keyed on campaign role, both audited by the same log (→ usage-royalty telemetry).

---

## 6. Third-party landscape (surveyed, for when we revisit buy-vs-build)

The category exists ("sync engine" / "local-first backend"), and it's a perennial business —
the polished versions keep getting abandoned, which both proves the value and warns against
coupling to any one.

- **Couchbase Mobile** (Couchbase Lite + Sync Gateway) — the closest match. Its **channels**
  are per-participant slices: docs are tagged with channels, users are granted channels, and
  the `_changes` feed only delivers what you can see. Granting a channel backfills its docs —
  essentially our "reveal as a new event." ~a decade old (CouchDB replication + changes feed).
- **PowerSync** / **ElectricSQL** — Postgres → on-device SQLite with "sync rules" / "shapes"
  that define each client's partial slice. Keeps the SQL affinity; the rules ≈ our per-scope
  cursors. **Rocicorp's Zero** is the same idea via query + permission-based sync.
- **Ditto** — offline-first with a peer-to-peer mesh; also covers the *in-the-room, no-internet*
  table case (the Multipeer angle, vision §4).
- **MongoDB Realm / Atlas Device Sync** — was the most turnkey (flexible sync = per-user query
  subscriptions + roles, exactly this) — and MongoDB **deprecated it** (announced 2024, sunset
  2025). The cautionary tale.
- **AWS AppSync + Amplify DataStore** — AWS's version: offline local store, delta sync with a
  lastSync/token table, `@auth` rules for per-user filtering. Functional but rough DX — itself
  evidence of how hard the general case is.

If/when we revisit: PowerSync/Electric/Zero (Postgres) or Couchbase (channels) could carry the
oplog + cursor + projection so we don't hand-roll it — behind our own stable interface, per §3.

---

## 7. Portability guardrails (cheap insurance to buy now)

These keep every future option open without building anything:

- **Stable UUIDs as the real identity.** `Adventurer.uid` already is this — the id that
  survives migrating off CloudKit onto our own backend. Every syncable model carries its own
  UUID; don't lean on SwiftData's `PersistentIdentifier` for cross-system identity.
- **Keep the domain model plain / serializable.** No CloudKit-isms leaking into the types. If
  it can cleanly become JSON, it can cleanly become a Postgres row and an oplog event later.
- **Design the sync *semantics* vendor-neutral now** (the event-log/cursor shape above), even
  though it isn't built — that's the insurance the graveyard demands.

---

## 8. Sequencing

1. **Now (Phases 1–3):** local-first, offline. Nothing to build here. Just keep the
   portability guardrails (§7).
2. **Player sync (earliest paid feature):** CloudKit + SwiftData for personal cross-device
   sync. Spike early to confirm the *whole* schema is CloudKit-legal.
3. **Campaign tier (Phase 4+):** our own Postgres-backed sync layer (§4–5), or a commercial
   engine behind our interface (§6). Real-time via push/subscriptions; Multipeer for in-room.
4. **Marketplace (Phase 5):** the usage-royalty ledger and telemetry ride on the same event
   log; content policy + payouts are separate infrastructure (vision §11).
