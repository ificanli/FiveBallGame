## 1. Approved baseline and scope safety

- [x] 1.1 Record M3.5 Gate P approval commit (UI-only phase), M3 rollback point, CUT list (audio, gamepad, full settings, Steamworks, PvP, meta, art, new content, rule tuning, balance tuning).
- [x] 1.2 Create `feature/ui-interaction-and-build-polish` from clean approved planning commit; run full M1/M2/M3 suite and replay baselines before any UI change (86/86 baseline).
- [x] 1.3 Build requirement-to-test traceability for the two new capabilities and the three modified capabilities (test_m35_ui_content, test_m35_ui_panels).

## 2. UI node foundation

- [x] 2.1 Write failing tests that audit scene structure: node panels exist, forbidden prototype labels absent, rule logic stays out of UI nodes.
- [x] 2.2 Split `technical_table.gd` into table draw layer (balls, walls, rails, trajectory) and node-based panels; keep `_draw()` only for table content.
- [x] 2.3 Add theme/font/color/spacing constants shared by all panels (`UiTheme`).
- [x] 2.4 Prove command-equivalence: full rule suite (93/93) and M3 run replay (3 seeds × 20 repeats, zero drift) pass after UI rework.

## 3. Interaction completeness

- [x] 3.1 Add main menu (开始巡回 / 教程 / 退出) with keyboard and mouse parity.
- [x] 3.2 Add pause menu (继续 / 徽章管理 / 重开 / 回主菜单).
- [x] 3.3 Add reward three-card panel with click, Chinese description, build tag, keyboard 1–3.
- [x] 3.4 Add tool selector: open with Q, pick specific tool, cancel; target selection for chalk/sticker/hook.
- [x] 3.5 Add badge management: replace on full slots, reorder (↑/↓), show Chinese description and build/role tags.
- [x] 3.6 Add settle/keep/bust action panel with explicit buttons and result feedback.
- [x] 3.7 Add run end/statistics panel showing table results, badges, statistics, final score, export hint.
- [x] 3.8 Add step-by-step tutorial guide (phase-driven Chinese hints, dismissible).

## 4. Chinese content coverage

- [x] 4.1 Add `badge.<id>.desc` for all 18 badges.
- [x] 4.2 Add `tool.<id>.desc` for all 6 tools.
- [x] 4.3 Extend audit to reject missing/empty keys and forbidden English prototype labels.
- [ ] 4.4 Test longest-text wrapping and no tofu glyphs at 1280×720 and 1920×1080 in exported build (HUMAN_QA).

## 5. Build identity polish

- [x] 5.1 Add UI-only build identity constants (color + label) for pure_combo / rail_chain / wall_risk; reused in reward, badge, HUD.
- [x] 5.2 Verify identity stays out of rule data (badges carry no visual fields; identity is display-only).
- [ ] 5.3 Record hidden-score build recordings; product owner identifies builds by shot choices only (HUMAN_QA).

## 6. Regression and Gate I

- [x] 6.1 Re-run full suite (93/93), golden replay smoke, M3 run replay (3×20 zero drift), Windows export + headless launch.
- [ ] 6.2 Human QA on exported Windows build: menus, reward, tool, badge replace, settle/keep/bust, tutorial, both resolutions.
- [ ] 6.3 Record Gate I evidence and product-owner acceptance; do not auto-start next milestone.
