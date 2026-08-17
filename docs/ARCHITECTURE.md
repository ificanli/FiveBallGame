# Architecture baseline (M0)

- Godot nodes are presentation/input adapters, never the source of rule truth.
- Future physics and rules live in data-oriented modules under `src/physics` and `src/rules`.
- Prediction and motion must eventually call the same deterministic `PhysicsSimulator`.
- Seed, initial snapshot, shot input, events, final states, ticks, and state hash form the Golden Replay boundary.
- M0 contains no gameplay physics. Its replay case validates only the serialized contract.
- Network and Steam APIs must not enter rule modules.
