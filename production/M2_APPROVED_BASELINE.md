# M2 Approved Baseline

- Change: `single-player-core-loop`
- Gate P: approved by product owner on 2026-08-18
- Approved main commit / rollback point: `7d17737a2f49b336c9cd006be35292e721c12c23`
- Feature branch: `feature/single-player-core-loop`
- Godot: 4.7.1 stable (`a13da4feb`)
- OpenSpec: 1.9.0; strict validation passed
- M1 baseline at branch creation: GdUnit4 51/51, zero failures; Golden Replay contract command exit 0

## Locked M2 scope

Collision collection; uncollected/hand/waste lifecycle; five hand slots; physical-ID ownership; copy slots and dye synchronization; one deterministic best combination; settle/keep; sixth-slot bust; fixed tutorial table with score, strokes, win/loss/reset; deterministic Headless session evidence; exported-build human QA.

## Combo rules version `m2-combo-1`

- Single ×1, pair ×3, three of a kind ×7, bomb ×15, five-ball grand slam ×30.
- Straight / same color / same-color straight:
  - 3 slots: ×5 / ×5 / ×12
  - 4 slots: ×7 / ×7 / ×18
  - 5 slots: ×10 / ×10 / ×25
- Best candidate order: score, multiplier, participant count, lexicographically earliest slot indices.

## CUT

Ball replenishment, pockets and cleanup items, badges, rewards, 24-table Run, dealer rules, save data, Steamworks, PvP, formal art/content production.
