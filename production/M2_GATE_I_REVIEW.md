# M2 Gate I Engineering Review

Status: `PASS_ENGINEERING_LOCAL / HUMAN_QA_REQUIRED`.

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

Runs before `e6c27bd` proved both Windows and Linux verification commands green but repeatedly failed while transferring Windows replay files. Commit `e6c27bd` replaces fragile direct artifact output with a two-step persisted log capture. Run `32184599980` exists for that commit; its final conclusion must be rechecked after the anonymous GitHub API rate limit resets before CI is marked complete.

## Remaining gate

- Human exported-build session of at least 15 minutes.
- Confirm final remote CI conclusion; if red, continue workflow repair without weakening verification.
