# Five Ball Grand Slam

Steam production repository for 《五球满贯》.

## Locked tooling

- Godot 4.7.1 stable (`a13da4feb`)
- GdUnit4 v6.2.0
- OpenSpec 1.9.0
- Git + Git LFS

## Local verification

Set `GODOT_BIN` to the Godot console executable if `godot_console.exe` is not on PATH.

```bat
tools\run_tests.cmd
tools\run_golden_replay.cmd
```

Headless project smoke:

```bat
%GODOT_BIN% --headless --path . --editor --quit
%GODOT_BIN% --headless --path . --quit-after 2
```

M0 is tooling only. Do not implement M1 without approval of the `deterministic-physics-table` OpenSpec change.
