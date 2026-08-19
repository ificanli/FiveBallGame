## 1. Approved baseline and scope safety

- [x] 1.1 Record M3 Gate P approval commit, M2 rollback point, exact 18-badge roster, six tools, three tables, CUT list and Chinese UI requirement.
- [x] 1.2 Create `feature/buildcraft-mvp` from clean approved planning commit over `main`; run the 71-case M1/M2 suite and single-repeat M1/M2 replay baselines before rule changes, retaining full-repeat/stress for Gate I.
- [x] 1.3 Build requirement-to-test traceability and content-role matrix proving three builds each have starter/core/amplifier/risk-or-finisher roles and at least 13/18 decision-changing badges.

## 2. Simplified Chinese foundation

- [x] 2.1 Add keyed Simplified Chinese localization resources for existing M2 HUD, controls, phases, combo names, result and error messages while retaining English internal IDs.
- [x] 2.2 Replace all current player-visible English prototype literals with localization lookups; add automated forbidden-label and missing-key audits.
- [ ] 2.3 Add a redistributable Chinese font/fallback decision with license record and layout tests at 1280×720 and 1920×1080.
- [ ] 2.4 Add Chinese names/descriptions/tags for all M3 badges, tools, tables, rewards and statistics; test longest-text wrapping and no tofu glyphs in exports.

## 3. Run data model and deterministic random streams

- [x] 3.1 Write failing tests for versioned `RunSnapshot`, badge instances/order/growth, inventory, reward state, table index, statistics and canonical round-trip/hash.
- [x] 3.2 Implement pure-data Run model with no Node references and explicit legal commands/phases.
- [x] 3.3 Implement named `reward`, `replenishment`, and `table` Seed streams with persisted counters; test that preview/UI lifecycle never consumes randomness.
- [x] 3.4 Add validators rejecting unknown content IDs, duplicate badge instances where forbidden, over-capacity inventories, invalid phases, non-finite score data and incompatible versions.

## 4. Settlement context and badge pipeline

- [x] 4.1 Write failing tests that freeze power, rail hits, activation depth, copy/dye events, best-combo participants, pollution, keep history and final-stroke evidence by stable IDs.
- [x] 4.2 Implement immutable `SettlementContext` generated from M2 snapshots/events and reused by preview, settlement and replay.
- [x] 4.3 Write table-driven tests for ordered `+基础分`, `+倍率`, `×倍率`, non-trigger steps, integer arithmetic, bounds and preview/commit equality.
- [x] 4.4 Implement deterministic `BadgeSettlementPipeline` and serializable per-badge trace; commit growth only on real settlement.

## 5. Eighteen-badge content

- [x] 5.1 Add schema/config audit and failing tests for the approved 6 pure-combo badges: 双生环、顺行仪、纯色灯、完美球组、牌型升级器、纯色顺大奖.
- [x] 5.2 Implement and balance the six pure-combo badges with participant/pollution and growth edge cases.
- [x] 5.3 Add tests and implementation for the approved 6 rail-chain badges: 贴库客、第五档、轻推大师、连锁反应、反弹专家、多米诺.
- [x] 5.4 Add tests and implementation for the approved 6 wall-risk badges: 复印税、调色盘、双充能镜、墙体回路、满仓红利、贪心基金.
- [x] 5.5 Add reorder, five-slot, replacement, cross-table growth and new-run reset tests; reject arbitrary scripted effects and any unregistered handler.
- [x] 5.6 Run counterfactual route fixtures for all 18; replace or structurally revise zero-trigger/unconditional/directionless badges instead of padding the catalog.

## 6. Six consumable tools

- [x] 6.1 Implement inventory, target-selection, cancel and atomic command tests with three-card capacity and deterministic replay.
- [x] 6.2 Write and pass soft-pocket tests for physical/copy sixth slots, continued motion, single consumption and no post-bust rescue.
- [x] 6.3 Write and pass insurance-slot tests for temporary six-slot evaluation, forced settle, no keep and capacity restoration.
- [x] 6.4 Implement chalk, number sticker and return hook with physical-ID synchronization, legal target filtering and invalid-range rejection.
- [x] 6.5 Implement table reset preserving banked score/strokes/Build/table rules while clearing hand and deterministically rebuilding legal balls.
- [x] 6.6 Add Chinese tool interaction UI and tests proving presentation cannot consume inventory before a valid committed command.

## 7. Controlled replenishment and density safety

- [x] 7.1 Write failing tests for 6/8/10 uncollected targets, exact deficit spawning, no RNG consumption when full and settlement/bust triggers.
- [x] 7.2 Implement deterministic batch generation over versioned spawn points with wall/ball/cue-zone overlap validation and stable IDs.
- [x] 7.3 Add minimum-change controlled generation tests for basic opportunities without guaranteed premium hands.
- [x] 7.4 Add blocked-spawn recovery and ten-waste oldest-first safety cleanup; prove cleanup awards no score or badge triggers.
- [x] 7.5 Add dense-table stress across Seeds and all table layouts, asserting finite state, bounded attempts, no overlap and reproducible hashes.

## 8. Three-table Run and rewards

- [x] 8.1 Define versioned qualification/high-stakes/dealer configurations with fixed derived Seeds, layouts, walls, tuning values, replenishment targets and Chinese names.
- [x] 8.2 Implement Run phase machine: start reward → table 1 → reward → table 2 → reward → table 3 → win/loss summary.
- [x] 8.3 Implement deterministic constrained three-choice rewards, no reopen refresh, no duplicate candidates, starter-only opening pool and at least one synergy candidate later.
- [x] 8.4 Implement five-slot replacement/decline flow and prevent a nonexistent post-dealer reward or score carryover between tables.
- [x] 8.5 Add multi-table Headless cases for three representative builds, losses on each table, same-Seed restart, new-Seed run, reward reopen and terminal input lock.
- [x] 8.6 Repeat every Run case 100 times and compare command/events/rewards/replenishment/scores/growth/terminal hash without weakening M1/M2 suites.

## 9. Presentation, Chinese interaction, and statistics

- [ ] 9.1 Build Chinese main entry, reward cards, run progress, ordered badge rail, tool inventory, final formula trace and table transitions from snapshots.
- [ ] 9.2 Add restrained trigger feedback distinguishing `+基础分`, `+倍率`, `×倍率`, with skip/fast-forward and no rule-state ownership in animations.
- [ ] 9.3 Implement local structured statistics and privacy-safe one-click JSON export for win/failure/abandon paths.
- [ ] 9.4 Add UI adapter tests for Chinese labels, legal actions, reward persistence, replacement, six-slot forced settle and terminal summaries.

## 10. Automated balance evidence

- [x] 10.1 Implement seeded legal-random, heuristic and Build-aware agents against the same production rules; version and document each policy.
- [x] 10.2 Run paired no-badge/pure-combo/rail-chain/wall-risk simulations over shared Seeds; report confidence intervals, percentiles, table death walls, trigger rates and decision logs.
- [x] 10.3 Add gates for never-triggered content, invalid reward choices, non-finite/explosive scores, dominant options and visually homogeneous proxy routes.
- [x] 10.4 Perform targeted counterfactual ablations for core badges and tools; explicitly state that automation does not prove fun.

## 11. Regression, CI, export, and independent review

- [x] 11.1 Run full GdUnit4, M1 Golden, M2 sessions, M3 Run replays, configuration/localization audits and stress tests; never rewrite approved expected results to hide regressions.
- [ ] 11.2 Resolve or formally isolate the GitHub Windows full-replay runtime problem while retaining local Windows and cloud Linux complete repeat evidence; do not lower approved repeat counts silently.
- [ ] 11.3 Export clean-clone Windows/Linux candidates, smoke both where supported, verify Chinese font assets/licenses and collect logs without blocking errors.
- [ ] 11.4 Conduct independent Gate I scope, architecture, content quality, secrets, rollback and evidence review.
- [ ] 11.5 Prepare M3 human checklist and three score-hidden representative Build recordings from reproducible Seeds.

## 12. Human gate and delivery

- [ ] 12.1 Obtain a real exported-build Run and record actual 15–25 minute timing, Chinese comprehension, reward understanding, tool use, route changes, result and blockers.
- [ ] 12.2 Obtain a human score-hidden comparison of the three Build recordings; if they look the same or badges do not change routes, mark REVISE and stop content expansion.
- [ ] 12.3 Fix blocking/spec issues with regression evidence; route material scope/identity changes through updated Gate P.
- [ ] 12.4 Update status, milestone, backlog, balance report, human record and evidence boundary; stop for approval before sync/archive and merge.
