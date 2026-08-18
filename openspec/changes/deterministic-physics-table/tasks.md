## 1. Branch, fixtures, and failing contracts

- [x] 1.1 Create `feature/deterministic-physics-table`, record the approved Change revision, and confirm the M0 test/export baseline still passes before implementation.
- [x] 1.2 Extract 5–10 read-only webpage reference shots into a documented comparison sheet with initial layout, direction, power level, expected first contact, stopping rhythm, and human-review notes.
- [x] 1.3 Add failing GdUnit4 tests for replay schema validation, invalid power/direction input, deterministic IDs, canonical serialization, non-finite rejection, and stable state Hash.
- [x] 1.4 Replace the M0 placeholder case with a versioned replay fixture format while preserving an explicit migration test for the old contract-only case.

## 2. Pure data model and versioned configuration

- [x] 2.1 Implement serializable ball, wall, table snapshot, shot input, physics config, event, and simulation-result data types without Node dependencies.
- [x] 2.2 Add stable integer ID allocation, explicit Seed/RNG initialization, full snapshot serialization, and schema/physics/content version fields.
- [x] 2.3 Implement canonical field ordering, comparison-grid normalization, deterministic Hash generation, and structured first-difference reporting.
- [x] 2.4 Add validation that rejects missing fields, unsupported versions, invalid IDs, overlaps outside the accepted correction range, invalid power/direction, and non-finite values.

## 3. Fixed-step motion and collision core

- [x] 3.1 Add failing tests for free motion, render-rate independence, friction decay, low-speed snap, smooth timeout termination, and exact shot-end detection.
- [x] 3.2 Implement the `1/120s` fixed-step loop, bounded deterministic substep calculation, friction, stop thresholds, low-speed finish, and maximum-duration finish.
- [x] 3.3 Add failing tests for direct, angled and glancing equal-mass circle collisions, initial-overlap correction, dense multi-ball contact, and maximum-power tunneling.
- [x] 3.4 Implement circle broad-phase candidate collection, stable contact keys, circle—circle impulse resolution, positional correction, finite-state guards, and fixed solver iterations.
- [x] 3.5 Add failing tests for perpendicular/angled rail impacts, adjacent-rail corner approaches, boundary containment, and independent rail restitution.
- [x] 3.6 Implement circle—rail collision and stable corner/contact ordering without using Godot physics bodies as rule truth.
- [x] 3.7 Run targeted stress tests and document whether bounded substeps meet tunneling and performance gates; if they fail, stop and propose time-of-impact scope instead of continuing.

## 4. Activation and function-wall slice

- [x] 4.1 Add failing tests for cue-to-number activation, number-to-number propagation, stable activation source/order, and non-active wall impacts.
- [x] 4.2 Implement per-shot activation causality from ordered physical contact events.
- [x] 4.3 Add failing tests for charged/exhausted copy walls, cue-ball exclusion, actual-impacting-ball ownership, and per-shot charge reset.
- [x] 4.4 Implement copy-wall result events without spawning a physical ball or introducing hand/combo rules.
- [x] 4.5 Add failing tests for dye-wall ball-ID targeting, number preservation, multiple active balls, cue-ball exclusion, and color state serialization.
- [x] 4.6 Implement dye-wall state changes and structured old/new color events for the actual impacting active ball.

## 5. Shot input and shared-source prediction

- [ ] 5.1 Add failing tests for all five fixed power mappings, replay round-trips, zero/non-finite direction rejection, and equivalent repeated input.
- [ ] 5.2 Implement legal shot creation with five discrete power levels and reproducible serialized direction.
- [ ] 5.3 Add failing tests that compare predicted and actual first collision object/type/order, including copy-wall and dye-wall routes.
- [ ] 5.4 Implement one simulation entry point used by both full motion and cloned-snapshot prediction; prohibit UI-local collision formulas.
- [ ] 5.5 Implement concise, standard, and full prediction budgets and outputs, with stale-request cancellation/cache keys and no automatic best-shot recommendation.
- [ ] 5.6 Measure prediction latency for the seven-ball technical table and record mode budgets; optimize only with evidence.

## 6. Golden Replay execution and coverage

- [ ] 6.1 Implement the Headless replay runner for valid/invalid cases with structured success, validation error, non-finite error, stop reason, events, final states, ticks, and Hash.
- [ ] 6.2 Implement explicit golden comparison and opt-in update commands; normal tests and CI must never overwrite expected data.
- [ ] 6.3 Create 15–20 reviewed Golden cases covering direct/angled/glancing hits, chains, dense contact, rails/corners, low speed, timeout, overlap correction, maximum power, copy, dye, and prediction first contact.
- [ ] 6.4 Add a manifest/category audit so CI fails when case count or required coverage categories regress.
- [ ] 6.5 Add a 100-repeat determinism command and retain a compact failure Artifact with the first divergent run/tick/event/state.

## 7. Technical table and debug presentation

- [ ] 7.1 Build a fixed-Seed Godot technical table scene with one cue ball, six number balls, standard rails, one copy wall, one dye wall, and no production art dependency.
- [ ] 7.2 Implement the scene adapter that renders rule snapshots and interpolates visuals without feeding node transforms back into simulation state.
- [ ] 7.3 Add aiming, five-level power selection, shot confirmation, restart/same-Seed controls, and concise/standard/full assistance switching.
- [ ] 7.4 Add debug overlays for IDs, number/color, velocity, contact points, activation source, wall charge, predicted path, Seed, tick, stop reason, and state Hash.
- [ ] 7.5 Add minimal, clearly subordinate feedback for collision, activation, copying and dyeing so the triggering ball/wall can be visually inspected.

## 8. CI, real startup, and review gates

- [ ] 8.1 Extend CI to run unit tests, Golden coverage, 100-repeat determinism, and Headless technical-table startup on the locked Godot version.
- [ ] 8.2 Run normalized Golden outputs on Windows and Linux, compare them, and upload both outputs plus structured diffs when they diverge.
- [ ] 8.3 Verify clean-clone Windows/Linux exports exclude tests/tools/addons and successfully start at the technical-table entry point.
- [ ] 8.4 Perform a real local visual/input review at target resolution; capture evidence for all five powers, all assistance modes, copy targeting, dye targeting, restart, and shot termination.
- [ ] 8.5 Execute the documented webpage comparison shots and record machine facts separately from the author's human assessment of control, bounce intuition, stopping rhythm, and overall feel.
- [ ] 8.6 Run an independent Gate I review against every requirement; record deviations, regression evidence, commit, and rollback point.
- [ ] 8.7 Update `production/PROJECT_STATUS.md`, risks, tuning notes, test evidence, and Change task checkboxes; do not mark M1 passed until the human feel gate explicitly passes.
