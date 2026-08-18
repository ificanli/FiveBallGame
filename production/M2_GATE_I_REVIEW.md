# M2 Gate I Engineering Review

Status: `IN_PROGRESS` until CI and human QA complete.

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

## Remaining gates

- Core-loop seeded stress and final strict validation.
- Remote Windows/Linux CI result and normalized output comparison.
- Independent clean-clone review.
- Human exported-build session of at least 15 minutes.
