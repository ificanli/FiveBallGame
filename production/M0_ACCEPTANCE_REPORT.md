# M0 acceptance report

Date: 2026-08-17  
Result: **VERIFYING — local technical gate passed; remote CI and commit identity remain blocked.**

## Completed

- Godot 4.7.1 stable exact build recorded and CLI/editor-headless startup verified.
- Git 2.52.0 and Git LFS 3.7.1 initialized in the production repository.
- OpenSpec 1.9.0 initialized; `openspec doctor` reports root OK; telemetry disabled globally.
- GdUnit4 v6.2.0 vendored at commit `d187702...`; two M0 tests pass headlessly.
- Minimal project starts and logs `FIVE_BALL_GRAND_SLAM_READY`.
- Golden Replay contract loads one JSON case and outputs structured JSON with `physics_executed:false`.
- Matching 4.7.1 export templates installed locally; Windows and Linux empty builds exported.
- Export boundary excludes tests, tools, docs, status, OpenSpec, reports, and addons.
- Exported Windows executable starts in headless mode with exit 0.
- CI definition runs import, GdUnit4, Golden contract, startup smoke, and matrix exports with artifacts.
- No gameplay physics, content batch, networking, Steamworks, or MCP was introduced.

## Evidence commands

```text
Godot_v4.7.1-stable_win64_console.exe --version
Godot ... --headless --editor --path . --quit
Godot ... --headless --path . --quit-after 2
Godot ... -s -d --headless res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode --add tests/unit
Godot ... --headless --path . --script res://tools/golden_replay_smoke.gd
Godot ... --headless --path . --export-release "Windows Desktop" builds/windows/FiveBallGrandSlam.exe
Godot ... --headless --path . --export-release "Linux/X11" builds/linux/FiveBallGrandSlam.x86_64
builds/windows/FiveBallGrandSlam.exe --headless --quit-after 2
openspec doctor
git lfs env
git check-attr filter -- assets/example.png
```

## Outputs

- Windows: `builds/windows/FiveBallGrandSlam.exe` — 109,117,512 bytes (ignored build output)
- Linux: `builds/linux/FiveBallGrandSlam.x86_64` — 73,516,408 bytes (ignored build output)
- Logs: `reports/` (ignored local evidence output)

## Issues found and fixed

1. GdUnit4 v6.2.0 rejects headless mode unless `--ignoreHeadlessMode` is explicit. Runner and CI updated.
2. Initial export included the whole vendored test framework and crashed during Windows packaging. Export filters now isolate production scenes/scripts and both exports pass.

## Remaining risks / blockers

- Cloud CI has not run because no Git remote is configured.
- A legitimate initial commit cannot be made until repository author identity exists; no identity was fabricated.
- Linux executable startup still needs a Linux runner/host.
- Machine checks prove tooling reproducibility only. They say nothing about gameplay quality.

## M1 guard

Do not implement M1. After M0 passes, create the `deterministic-physics-table` OpenSpec proposal/specs/design/tasks and wait for explicit Gate P approval.
