## 1. Approved baseline and scope safety

- [ ] 1.1 Record M3.5 Gate P approval commit, M3 rollback point, exact scope (UI interaction + build polish), CUT list (audio, gamepad, full settings, Steamworks, PvP, meta, art).
- [ ] 1.2 Create `feature/ui-interaction-and-build-polish` from clean approved planning commit over `main`; run full M1/M2/M3 suite and single-repeat replay baselines before any UI change.
- [ ] 1.3 Build requirement-to-test traceability for the two new capabilities and the three modified capabilities.

## 2. UI node foundation

- [ ] 2.1 Write failing tests that audit scene structure: no rule logic inside UI nodes, commands are the only mutation path, forbidden prototype labels still absent.
- [ ] 2.2 Split `technical_table.gd` into table draw layer (balls, walls, rails, trajectory) and node-based panels; keep `_draw()` only for table content.
- [ ] 2.3 Add theme/font/color/spacing constants shared by all panels; verify 1280×720 and 1920×1080 layouts.
- [ ] 2.4 Prove command-equivalence: same command sequence through UI and Headless yields identical replay hash.

## 3. Interaction completeness

- [ ] 3.1 Add main menu (开始巡回 / 教程 / 退出) with keyboard and mouse parity.
- [ ] 3.2 Add pause menu (继续 / 重开 / 回主菜单), only available when ball is still.
- [ ] 3.3 Add reward three-card panel with hover, click, Chinese description, build tag, keyboard 1–3.
- [ ] 3.4 Add tool selector: open with Q, pick specific tool and legal target, cancel; replace "use first available".
- [ ] 3.5 Add badge management: replace on full slots, reorder, show per-badge Chinese description and build/role tags.
- [ ] 3.6 Add settle/keep/bust action panel with explicit buttons and result feedback.
- [ ] 3.7 Add run end/statistics panel showing table results, badges equipped, tool usage, final score, JSON export hint.
- [ ] 3.8 Add step-by-step tutorial guide on the tutorial table, still completable in Simplified Chinese only.

## 4. Chinese content coverage

- [ ] 4.1 Add `badge.<id>.desc` for all 18 badges: trigger condition + effect + value, no marketing filler.
- [ ] 4.2 Add `tool.<id>.desc` for all 6 tools: target, legal timing, cost, effect.
- [ ] 4.3 Extend audit to reject missing/empty/duplicate keys and over-long non-wrapping single lines.
- [ ] 4.4 Test longest-text wrapping and no tofu glyphs at both resolutions in exported build.

## 5. Build identity polish

- [ ] 5.1 Add UI-only build identity constants (color + label) for pure_combo / rail_chain / wall_risk; reuse in reward, badge, settlement detail, statistics.
- [ ] 5.2 Verify identity matches real trigger conditions; reject decorative mismatches.
- [ ] 5.3 Run counterfactual route fixtures for three builds and record candidate balance adjustments without changing values.
- [ ] 5.4 Record hidden-score build recordings; product owner identifies builds by shot choices only; automated agent must not substitute this verdict.

## 6. Regression and Gate I

- [ ] 6.1 Re-run full M1/M2/M3 suite, golden replays, cross-platform export and hash comparison after UI rework.
- [ ] 6.2 Human QA on exported Windows build: full run, menus, reward, tool, badge replace, settle/keep/bust, tutorial, both resolutions.
- [ ] 6.3 Record Gate I evidence and product-owner acceptance; do not auto-start next milestone.
