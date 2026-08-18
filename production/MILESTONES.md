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
Status: `BACKLOG / NOT APPROVED FOR IMPLEMENTATION`

Entry gate: a separate OpenSpec proposal/spec/design/tasks and explicit user Gate P approval.

## M3 — Buildcraft MVP
Status: `BACKLOG`

## M4 — Local hot-seat PvP black box
Status: `BACKLOG / HYPOTHESIS`

## M5 — Releaseable vertical slice
Status: `BACKLOG`
