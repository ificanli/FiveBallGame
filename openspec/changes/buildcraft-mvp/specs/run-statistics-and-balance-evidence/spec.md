## ADDED Requirements

### Requirement: Run records local structured statistics
每局 Run SHALL 记录版本、Seed、开始/结束时间、每桌耗时与杆数、结算/保留/爆仓次数、组合分布、墙体事件、徽章选择与触发、道具使用、奖励候选、得分步骤和结束原因。统计 SHALL 仅本地保存，不在 M3 上传网络。

#### Scenario: Run ends
- **WHEN** Run 胜利、失败或被确认放弃
- **THEN** 系统 SHALL 生成可读摘要和可一键导出的版本化 JSON

#### Scenario: Export contains rule evidence
- **WHEN** 测试者导出 Run JSON
- **THEN** 文件 SHALL 足以复核 Build、关键决策和得分，不得包含本机用户名、绝对路径或秘密

### Requirement: Seeded agents compare builds without claiming fun
Headless 平衡工具 SHALL 使用至少三层策略代理，并对无徽章基线及三套代表 Build 在相同 Seed 集合上进行成对反事实运行。报告 SHALL 包含样本数、均值/中位数、分位数、胜率置信区间、桌级失败点、徽章触发率和输入策略说明。

#### Scenario: Build comparison runs
- **WHEN** 三套 Build 在同一批 Seed 和对应策略下批量模拟
- **THEN** 报告 SHALL 分离 Build 效果与策略效果，并保存逐局可复现输入或决策日志

#### Scenario: Report is presented
- **WHEN** 自动平衡报告生成
- **THEN** 结论 SHALL 仅描述稳定性、强弱、触发和可达性，不得把机器人胜率写成“好玩”证明

### Requirement: Balance gates reject degenerate content
机器门 SHALL 标记永不触发、无条件统治、奖励死选项、依赖不可达事件、导致非有限得分或使三套 Build 输出完全同质的徽章/道具。修复不得通过只提高所有目标分掩盖问题。

#### Scenario: Badge never triggers across its intended agent suite
- **WHEN** 某徽章在覆盖其声明玩法的种子化测试中触发率为零
- **THEN** M3 Gate I SHALL 失败或将该徽章从 18 枚正式池替换并重新验证

#### Scenario: One option dominates its reward peers
- **WHEN** 同层候选在成对反事实中表现出近乎无条件优势
- **THEN** 报告 SHALL 标记该选项供数值或触发条件复审，不得自动宣称平衡

### Requirement: Human evidence remains the product gate
三套 Build 是否肉眼可辨、玩家是否主动改变球路、奖励是否有期待感和 15～25 分钟节奏是否成立 SHALL 由真人记录。机器证据只作为异常定位与候选筛查。

#### Scenario: Automation passes but recordings look identical
- **WHEN** 自动测试全部通过但真人认为三套录像打法相同
- **THEN** M3 SHALL 判为 REVISE，先重构徽章而非继续增加数量
