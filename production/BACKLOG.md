# Backlog

| ID | Item | Status | Dependency / gate |
|---|---|---|---|
| M0-01 | Repository, directories, Git/LFS | DONE | — |
| M0-02 | Godot 4.7.1 install/version lock | DONE | — |
| M0-03 | OpenSpec initialization | DONE | — |
| M0-04 | GdUnit4 headless smoke | DONE | — |
| M0-05 | Golden Replay M0 contract skeleton | DONE | No physics |
| M0-06 | Local Windows/Linux empty exports | DONE | — |
| M0-07 | Windows exported build startup smoke | DONE | — |
| M0-08 | GitHub Actions workflow and Artifact jobs | DONE | Run `32018118216` success |
| M0-09 | Initial Git commit | DONE WITH RISK | `adb6e73`; auto-derived author must be confirmed before push |
| M0-10 | Independent M0 review | DONE | Fresh clone review: `PASS_ENGINEERING` |
| M0-11 | Godot MCP isolated evaluation | CUT FROM CURRENT M0 | Only after baseline stable; separate experiment branch |
| M1-01 | Create `deterministic-physics-table` OpenSpec Change | DONE | 4/4 artifacts; strict validation passed |
| M1-02 | Gate P review of M1 proposal/spec/design/tasks | DONE | User approved 2026-08-17 |
| M1-03 | Implement deterministic physics table | DONE | 44/44 tasks; engineering + human gates passed |
| M1-04 | Archive Change and integrate feature branch | DONE | Archived, synced, merged and pushed at `7642076` |
| M2-01 | Propose single-player core loop Change | DONE | Gate P approved; strict validation passed |
| M2-02 | Implement single-player core loop | DONE | 71/71 tests; deterministic replay/stress; clean exports; Gate I and human acceptance |
| M2-03 | Sync specs, archive Change, and merge | DONE | Archived at `openspec/changes/archive/2026-08-19-single-player-core-loop`; merged to `main` at `04095d9` |
| M2-04 | Stabilize cloud Windows replay runtime | FOLLOW-UP | Run `32207178927`: Linux green; Windows 18×100 replay exceeds one hour despite local Windows pass |
| M3-01 | Propose buildcraft MVP with Simplified Chinese UI | IN_REVIEW | `buildcraft-mvp`; 4/4 artifacts and strict validation passed; Gate P required |
| M3-02 | Implement buildcraft MVP | BLOCKED | No implementation before explicit M3 Gate P |
