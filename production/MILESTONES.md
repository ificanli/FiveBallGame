# Milestones

## M0 — Toolchain and production repository

Status: `PASSED`  
Goal: establish a reproducible Godot production baseline without gameplay implementation.

MUST: Godot lock, Git/LFS, OpenSpec, GdUnit4, headless smoke, Golden Replay contract, Windows/Linux empty export, CI definition, persistent project status.  
CUT: gameplay physics, content production, Steamworks, networking, MCP trial.

Pass gate: all local evidence passes; cloud CI produces both artifacts after remote setup; initial commit and independent review complete.

## M1 — Deterministic physics table

Status: `PASSED`

Evidence: approved and completed OpenSpec change `deterministic-physics-table`; 51/51 unit tests; 18 Golden cases × 100 repeats; Windows/Linux CI comparison; clean exports; independent Gate I; explicit human approval.

## M2 — Single-player core loop
Status: `PASSED`

Evidence: approved OpenSpec change `single-player-core-loop`; 71/71 GdUnit4 tests; 8 deterministic session classes × 100 repeats; 500 seeded stress sessions; clean Windows/Linux exports and Windows startup; independent Gate I; explicit product-owner acceptance. The product owner accepted the English prototype for M2 and made Simplified Chinese player UI mandatory for M3.

Known CI engineering risk: GitHub Actions run `32207178927` passed Linux verification, while its Windows 18-case ×100 replay remained long-running for more than one hour. Local Windows replay and clean-clone Windows evidence passed; the cloud Windows runtime issue is tracked rather than misreported as green.

## M3 — Buildcraft MVP
Status: `PLANNING / GATE P REQUIRED`

Entry gate: archive/sync M2, then approve a separate OpenSpec proposal/spec/design/tasks. M3 must include Simplified Chinese player-facing UI.

## M4 — Local hot-seat PvP black box
Status: `BACKLOG / HYPOTHESIS`

## M5 — Releaseable vertical slice
Status: `BACKLOG`
