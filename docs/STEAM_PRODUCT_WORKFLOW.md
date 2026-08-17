# 《五球满贯》AI 辅助 Steam 产品研发工作流 v1.0

更新时间：2026-08-17
适用范围：Godot Steam MVP、纵切、Demo 与正式版

> 核心原则：一次只推进一个可验收里程碑；设计、计划、实现、验证、真人试玩和发布必须留下持久化证据。

---

# 1. 权责

## 人类产品负责人

拥有最终决定权：

- 核心玩法与范围；
- 美术方向；
- 优先级；
- 是否好玩；
- 里程碑通过、返工或取消；
- 发布与商业决策。

## 主 AI 统筹窗口

负责：

- 维护唯一状态；
- 讨论并写规格；
- 拆分计划与排期；
- 实现或调度独立任务；
- 汇总机器证据；
- 接管验收；
- 提醒风险和范围漂移。

不得：

- 用自动测试宣布好玩；
- 未经批准改变核心；
- 同时推进多个共享文件的大功能；
- 将文档完成冒充实现完成。

## Reviewer / QA

应尽量使用独立上下文，负责：

- 计划覆盖与范围审查；
- 代码与回归风险；
- 测试证据质量；
- 真实入口启动；
- 规格与实现一致性。

---

# 2. 项目持久化文件

正式仓库必须存在：

```text
docs/
  PRODUCT_BRIEF.md
  GDD_CORE.md
  ARCHITECTURE.md
  ART_DIRECTION.md
  PVP_DESIGN.md
  PLAYTEST_LOG.md
  DECISIONS.md
  RISKS.md
production/
  PROJECT_STATUS.md
  MILESTONES.md
  BACKLOG.md
  sprints/
  retrospectives/
openspec/
tests/
```

其中 `production/PROJECT_STATUS.md` 是跨窗口唯一进度来源。

---

# 3. 两层计划

## 产品里程碑层

回答：未来 2～8 周交付什么。

每个里程碑必须包含：

- 目标问题；
- 玩家可见交付；
- MUST / SHOULD / CUT；
- 验收门；
- 时间盒；
- 风险；
- 失败与回退方案。

## OpenSpec 变更层

回答：本次具体功能怎么做。

固定产物：

```text
proposal.md
specs/
design.md
tasks.md
```

不得用一个 OpenSpec Change 覆盖整个 MVP。每个 Change 应在一个干净上下文中可实现、可审查。

---

# 4. 标准阶段循环

每个里程碑执行：

## A. Discuss（讨论）

- 明确玩家问题；
- 明确危险假设；
- 记录不做项；
- 更新 DECISIONS / RISKS；
- 未达共识不进入计划。

## B. Spec（规格）

- 创建 OpenSpec Change；
- 使用 Given / When / Then 写验收场景；
- 写技术设计和边界；
- 写任务与依赖；
- 计划必须覆盖全部验收条件，且无范围外任务。

### Gate P：计划审查

必须满足：

- 核心不变量未被破坏；
- 每条需求有任务；
- 每项任务服务某条需求；
- 测试和回退方案明确；
- 用户明确批准。

未通过不得编码。

## C. Implement（实现）

按小批次执行：

```text
写失败测试 / 回放案例
→ 实现最小功能
→ 测试通过
→ 实际启动
→ 更新进度
→ 小提交
```

单个批次目标 0.5～2 天。共享核心模块默认串行，不盲目并行。

## D. Verify（验证）

分四层：

1. L1 机器检查：语法、静态、单元测试；
2. L2 规则回归：Golden Replay、配置审计、存档迁移；
3. L3 真实运行：Godot 启动、目标分辨率、截图、输入、胜负；
4. L4 真人试玩：理解、手感、成长、节奏、乐趣。

### Gate I：实现审查

必须确认：

- 实现符合规格；
- 无未批准的范围变化；
- 测试不是只测复制逻辑；
- 真实入口可运行；
- 文档和版本已更新。

## E. Playtest（真人试玩）

每次试玩只回答预先定义的问题。记录：

- 测试版本与 commit；
- 玩家类型；
- 可观察事实；
- 玩家原话；
- 设计解释；
- 决策：通过 / 修改 / 无结论 / 淘汰。

自动胜率不能证明好玩。

## F. Ship（交付与归档）

- 生成候选构建；
- 完成发布清单；
- 归档 OpenSpec Change；
- 更新 PROJECT_STATUS；
- 写里程碑复盘；
- 创建下一里程碑，不在同一窗口无限续写。

---

# 5. 状态定义

任务状态：

- `BACKLOG`
- `READY`
- `IN_PROGRESS`
- `BLOCKED`
- `IN_REVIEW`
- `HUMAN_QA`
- `DONE`
- `CUT`

里程碑状态：

- `PLANNING`
- `APPROVED`
- `BUILDING`
- `VERIFYING`
- `PLAYTESTING`
- `PASSED`
- `REVISE`
- `STOPPED`

任何时刻最多一个主里程碑为 `BUILDING`。

---

# 6. Definition of Ready

功能进入开发前必须具备：

- 明确玩家价值；
- 规格与验收场景；
- 技术边界；
- MUST / CUT；
- 测试策略；
- 依赖已准备；
- 用户批准。

# 7. Definition of Done

功能完成必须具备：

- 规格实现；
- 自动测试；
- 物理相关 Golden Replay；
- 真实启动与截图；
- 无新增阻塞错误；
- 文档同步；
- Reviewer 通过；
- 涉及体验时完成真人验收；
- 已提交 Git。

---

# 8. 变更控制

## 小变更

同一 Change 内更新规格和任务，记录原因。

## 核心变更

影响以下任一项时，必须暂停实现并新开提案：

- 碰撞即收集；
- 五球槽与六球爆仓；
- 功能墙归属；
- 物理确定性；
- PvP 权威模型；
- 存档兼容；
- 单机 Run 结构。

## 紧急 Bug

可先修，但必须补：

- 回归测试；
- Bug 根因；
- 受影响版本；
- 是否需要更新规格。

---

# 9. AI 上下文纪律

- 主窗口负责产品与状态，不长期承载全部实现细节；
- 每个大 Change 使用新窗口或压缩后的干净上下文；
- 新窗口先读 PROJECT_STATUS、当前 Change 和相关架构；
- 完成后必须更新持久化文件；
- 不依赖聊天记录记进度；
- 不批量生成占位功能后声称完成；
- 不在没有真实运行证据时写“已通过”。

---

# 10. 分支与提交

```text
main             可发布
integration      日常集成
feature/*        已批准功能
experiment/*     物理、PvP、MCP、美术试验
release/*        发布候选
```

每次提交应小而可回退：

```text
feat(physics): add fixed-step circle collision
 test(replay): add bank-shot golden case
 fix(ui): prevent badge panel input leak
 docs(pvp): record host authority decision
```

---

# 11. 当前 MVP 里程碑门

## M0 工具链门

- Godot 固定版本；
- Git/LFS；
- GdUnit4；
- CI；
- OpenSpec；
- 空工程导出；
- 状态和里程碑文件。

## M1 物理门

- 五档力度；
- 圆—圆 / 圆—库边；
- 预测与实际同源；
- 15～20 条 Golden Replay；
- 100 次重复稳定；
- 手感不低于网页版。

## M2 核心闭环门

- 收球、三态、功能墙；
- 组合、结算、保留、爆仓；
- 教程桌可独立完成；
- 15 分钟内无阻塞 Bug。

## M3 构筑门

- 18～24 枚徽章；
- 三套打法；
- 至少 70% 徽章改变击球判断；
- 真人试玩能识别 Build 差异。

## M4 PvP 门

- 本地热座；
- 共享桌面与归属；
- 等待和挫败可接受；
- 若核心不成立则 CUT，不拖累单机。

## M5 发布候选门

- 正式 UI / 音效 / 设置；
- 存档与本地化；
- Windows 构建；
- 20～30 分钟纵切；
- 公开测试包与反馈入口。

---

# 12. 每周节奏

建议一周一个可验收目标：

- 周一：讨论、规格、计划审查；
- 周二至周四：实现与机器验证；
- 周五：集成、真实运行、内部试玩；
- 周末：外部试玩或复盘，不无止境补功能。

若里程碑失败，优先缩小范围或回退，不把未完成任务默默滚入下一周。
