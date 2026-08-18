# M1 trajectory preview benchmark

Date: 2026-08-17  
Environment: Windows 10, Godot 4.7.1 Headless, seven-ball seeded technical snapshot  
Iterations: 100 per mode, new preview service each iteration (no cache benefit)

| Mode | Tick budget | Average | Total |
|---|---:|---:|---:|
| concise | 90 | 5.95 ms | 594.80 ms |
| standard | 270 | 17.49 ms | 1749.23 ms |
| full | 480 | 39.30 ms | 3930.00 ms |

Decision: keep current budgets for the first visual technical table. Concise is comfortably interactive; standard is around one 60 Hz frame in worst-case uncached Headless measurement; full is intentionally more expensive and should be recalculated only after input pauses or served from cache. Real editor/UI latency still requires task 8.4 evidence.
