# M1 Golden Replay report

Date: 2026-08-17

## Evidence

- Unit suites: 49/49 passed, 0 errors/failures/skips/orphans.
- Golden cases: 18 (required range 15–20).
- Coverage audit: all required categories present: direct, angled, glancing, chain, dense, rail, corner, low-speed, timeout, overlap, maximum-power, copy, dye, prediction-first-contact.
- Repeat check: 100 runs per case, 1800 executions total, 0 state/event/tick divergence.
- Normal verify mode does not write fixtures.
- Fixture updates require explicit `--update`.
- Structured diff reports the first mismatching path.

## Finding for human tuning

With current reference drag and a six-second cap, many nontrivial shots terminate through `maximum_duration` rather than natural low-speed stop. This is deterministic and within the machine contract, but may feel too long or too abruptly collected. It remains a tuning/human-playtest question and is not counted as proof of acceptable feel.
