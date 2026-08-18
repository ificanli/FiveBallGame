## 1. Approved baseline and branch safety

- [x] 1.1 Record the user-approved Gate P commit, M2 scope, combo table, CUT list, Godot/OpenSpec versions, and rollback point in the production status files.
- [x] 1.2 Create `feature/single-player-core-loop` from the approved clean `main` and verify all M1 GdUnit4 and Golden Replay baselines before changing rules.
- [x] 1.3 Add a spec-to-test traceability checklist covering every M2 requirement and scenario group; confirm no task introduces badges, rewards, replenishment, Run progression, save data, PvP, or formal art production.

## 2. Core rule data model

- [ ] 2.1 Write failing GdUnit4 tests for three-state lifecycle transitions, stable physical IDs, non-repeat collection, and retained physical collisions.
- [ ] 2.2 Implement serializable collection state, hand slot, core-loop snapshot, wall charge, rule version, and explicit phase data without Godot scene-node references.
- [ ] 2.3 Implement canonical serialization, validation, cloning, and stable hashing for core-loop snapshots, including nullable physical IDs for copy slots.
- [ ] 2.4 Add tests rejecting duplicate physical-slot ownership, more than five persisted slots, invalid phase/command combinations, non-finite values, and inconsistent ball lifecycle state.

## 3. Collection and wall-event reduction

- [ ] 3.1 Write failing tests for cue collection, indirect activated collection, retained-hand reactivation on a later shot, waste-ball exclusion, and stable same-tick ordering.
- [ ] 3.2 Implement the deterministic core-loop event reducer over M1 physical events, with per-shot activation provenance and idempotent event consumption.
- [ ] 3.3 Write failing tests for copy slots with no physical ID, entity-to-slot dye synchronization, depleted wall behavior, and waste/cue/non-active wall contacts.
- [ ] 3.4 Integrate copy and dye events into the reducer so slot, ball, charge, and provenance updates occur atomically while preserving M1 event output.
- [ ] 3.5 Write and pass boundary tests where physical or copied sixth-slot acquisition causes immediate bust and all later rule effects in the moving shot are ignored.

## 4. Best-combination evaluator and base score

- [ ] 4.1 Add table-driven failing tests for single, pair, three of a kind, bomb, five-ball grand slam, and every three/four/five-slot straight, same-color, and same-color-straight multiplier.
- [ ] 4.2 Implement versioned combo data and exhaustive candidate evaluation over at most five slots, including copy slots and duplicate-number straight handling.
- [ ] 4.3 Add failing tests for pollution exclusion, overlapping candidates, equal-score tie breaks, slot-index stability, empty hands, and exact score arithmetic.
- [ ] 4.4 Implement deterministic best-combination selection and score preview with explicit participant and pollution slot indices.

## 5. Shot and post-shot state machine

- [ ] 5.1 Write failing command/state tests for valid launch consumption, aim/cancel no-cost behavior, movement input lock, and per-shot activation/charge reset.
- [ ] 5.2 Implement `AIMING`, `SIMULATING`, `POST_SHOT_DECISION`, `WON`, and `LOST` transitions with explicit rejected-command results.
- [ ] 5.3 Write failing tests for atomic settlement, kept hands across shots, no-score empty shots, target-reaching victory, and terminal input lock.
- [ ] 5.4 Implement settle and keep commands, including physical-hand-to-waste conversion, copy-slot disposal, score banking, and wall recharge at the next valid shot.
- [ ] 5.5 Write and pass zero-stroke tests for final settlement, unavailable keep, empty/busted final-shot loss, and below-target loss after final settlement.

## 6. Multi-shot deterministic replay

- [ ] 6.1 Define and validate a versioned core-loop session case/result schema while retaining the existing M1 single-shot replay schema unchanged.
- [ ] 6.2 Implement a Headless session runner that applies shot and decision commands and emits per-command events, snapshots, scores, strokes, phase, and canonical Hash.
- [ ] 6.3 Add rule replay cases for settle, keep-then-score, physical sixth-ball bust, copy-wall bust, dye synchronization, waste-ball later collision, final-stroke win, and final-stroke loss.
- [ ] 6.4 Repeat every M2 session case 100 times and fail on any event, snapshot, tick, phase, score, or Hash drift.
- [ ] 6.5 Extend Windows/Linux CI comparison to M2 session outputs without weakening the existing M1 Golden Replay comparison.

## 7. Tutorial table presentation and interaction

- [ ] 7.1 Create a versioned fixed-Seed tutorial configuration with layout, target, strokes, balls, copy/dye walls, and a documented reset baseline.
- [ ] 7.2 Add a tutorial-table scene/adapter that renders the core snapshot while reusing the M1 simulator, five powers, three preview modes, and input behavior.
- [ ] 7.3 Render target/current score, strokes, five hand slots, colors/numbers, best combo, participant/pollution emphasis, score preview, wall charges, and current legal actions.
- [ ] 7.4 Implement settle, keep, final-settle, and reset interactions with unavailable actions disabled rather than silently accepted.
- [ ] 7.5 Add visible collection, hand, waste, copy, dye-to-slot, bust, win, and loss feedback sourced from rule events; preserve readable IDs/colors during motion.
- [ ] 7.6 Add UI adapter tests proving that displayed slots, score, state, and legal actions derive from snapshots and cannot mutate rule truth.

## 8. Regression, stress, and independent verification

- [ ] 8.1 Run the complete GdUnit4 suite and all M1/M2 replays Headless; fix failures without rewriting approved expected results to hide regressions.
- [ ] 8.2 Add seeded stress sessions covering dense chains, repeated keep decisions, same-tick collections, copy/dye sequences, repeated reset, and all five powers; assert finite values and valid states.
- [ ] 8.3 Export Windows and Linux candidates from a clean clone, start the Windows export through the real entry point, and collect logs with no blocking errors.
- [ ] 8.4 Perform an independent Gate I review against proposal/spec/design/tasks, including scope audit, test quality, sensitive-file scan, and rollback verification.
- [ ] 8.5 Prepare `production/M2_HUMAN_QA_CHECKLIST.md` with build commit and observable checks for collection, three states, wall ownership, best combo, settle, keep, bust, win/loss, and reset.

## 9. Human gate and delivery

- [ ] 9.1 Obtain a human play session from the exported candidate lasting at least 15 minutes and record the required settle, keep, wall effect, bust, terminal result, reset, comprehension, predictability, and blocker observations.
- [ ] 9.2 Resolve any blocking or spec-nonconforming issue with regression evidence; route material rule/scope changes back through an updated Gate P instead of silently changing the baseline.
- [ ] 9.3 Update project status, milestones, backlog, playtest log, acceptance report, exact test/replay/CI evidence, and known non-blocking risks.
- [ ] 9.4 Mark all tasks only from evidence, commit the completed feature in reviewable batches, and stop for user approval before OpenSpec sync/archive and merge to `main`.
