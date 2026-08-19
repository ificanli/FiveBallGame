# M2 Gate I Engineering Review

Status: `PASSED WITH CLOUD WINDOWS RUNTIME FOLLOW-UP`.

## Scope review

Implemented only approved M2: lifecycle, five slots, combo/score, wall-slot integration, settle/keep/bust, tutorial win/loss/reset, deterministic session replay and presentation adapter. No badges, rewards, replenishment, Run progression, save data, Steamworks, PvP, pockets, cleanup tools, or formal content production were added.

## Architecture review

- Physics remains in `src/physics`; cross-shot truth is serializable pure data under `src/rules`.
- Scene adapter reads `CoreLoopSnapshot` and submits controller commands.
- M1 serialization/Golden hashes exclude the runtime-only waste eligibility set.
- Copy slots have no physical ID; dye synchronization is physical-ID based.
- Event-time copy values prevent copy-then-dye temporal leakage.

## Current machine evidence

- GdUnit4: 71/71, zero failures (`reports/m2-full-tests.log`).
- M2 rule replay: 8 required case classes × 100 repeats, zero drift (`reports/core-loop-local.json`).
- Windows/Linux local export: exit 0.
- Exported Windows candidate Headless startup: exit 0; `M2_TUTORIAL_READY` observed.
- M1 test suites remain included in the 71-case run.
- Seeded core-loop stress: 500 sessions across 20 Seeds × 5 powers × 5 repeats, zero drift/invalid/non-finite state.
- OpenSpec strict validation passed.
- Fresh remote clone at `e6c27bd`: 71/71 tests; 8 session classes × 100 repeats; Windows/Linux export exit 0; exported Windows startup observed `M2_TUTORIAL_READY`.
- Scope and sensitive-file review found no CUT-system implementation or committed credential.

## Remote CI note

- Run `32184599980` completed with failure; it is not treated as unknown or green.
- Cross-platform output handling was repaired and the Headless Golden runner now explicitly preloads physics scripts so a fresh Windows import does not depend on class-cache timing.
- Run `32207178927` passed the full Ubuntu verification matrix. Its Windows job passed checkout, Godot install, import and all 71 GdUnit4 tests, then remained in the full 18-case ×100 physical replay for more than one hour.
- The complete repeat count is intentionally retained. Local Windows and fresh-clone Windows replay/export/startup evidence remain green. Cloud Windows runtime optimization is tracked as follow-up rather than weakening the deterministic gate or falsely claiming CI success.

## Human gate

The product owner explicitly accepted the M2 candidate and requested Simplified Chinese UI in the next version. `production/M2_HUMAN_QA_RESULT.md` records the exact evidence boundary; no unreported per-check duration or observations are inferred.
