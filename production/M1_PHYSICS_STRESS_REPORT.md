# M1 bounded-substep stress report

Date: 2026-08-17  
Branch: `feature/deterministic-physics-table`

## Scope

- Seven balls: one cue plus six number balls.
- Maximum power level 5 (`1100` reference speed).
- Dense staggered chain at angles `-35, -20, -8, 0, 8, 20, 35` degrees.
- Each angle repeated 100 times from an identical snapshot and input.

## Result

```json
{"cases":7,"elapsed_ms":23956.845,"failures":[],"repeats_per_case":100,"status":"passed"}
```

- 700 repeated simulations completed.
- No state-hash or tick divergence.
- No non-finite position/velocity.
- No final overlap above the `0.01` audit tolerance.
- Unit suite at this stage: 31/31 passed.

## Decision

The fixed `1/120s` step plus bounded deterministic substeps meets the current seven-ball M1 stress gate. Continue with activation and function-wall work. A time-of-impact proposal is not required at this evidence level.

This does not prove every future dense layout is safe; Golden Replay and later long-run coverage remain required.
