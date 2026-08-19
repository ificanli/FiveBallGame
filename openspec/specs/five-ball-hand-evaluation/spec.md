# five-ball-hand-evaluation Specification

## Purpose

定义最多五格球组的身份模型、首版组合识别、确定性最佳组合选择与基础得分预览，使玩家和自动测试对“哪些球计分”得到同一答案。

## Requirements

### Requirement: Hand slots preserve source identity
当前球组 SHALL 最多保存五个槽位。物理收集槽 SHALL 保存来源物理球 ID；复制墙生成的槽位副本 SHALL 保存数字、颜色和来源事件，但 SHALL NOT 拥有或伪造物理球 ID。

#### Scenario: Physical ball enters a slot
- **WHEN** 一颗未收物理球被成功收集
- **THEN** 新槽位 SHALL 保存该球 ID、数字和当前颜色

#### Scenario: Copy result enters a slot
- **WHEN** 有充能的复制墙成功复制实际撞墙球且球槽有空位
- **THEN** 新槽位 SHALL 复制触发时的数字与颜色、标记为纯槽位副本，并且物理球 ID SHALL 为空

#### Scenario: Duplicate slot is later evaluated
- **WHEN** 最佳组合评价包含纯槽位副本
- **THEN** 副本 SHALL 与普通槽位一样参与组合与基础得分计算

### Requirement: The evaluator recognizes the M2 combination catalog
评价器 SHALL 识别单球、对子、三条、炸弹、五球满贯、顺子、同色和同色顺。顺子、同色与同色顺 SHALL 至少包含三格；顺子数字 SHALL 连续且不得以重复数字扩展长度；同色顺 SHALL 同时满足相同颜色与连续数字。

#### Scenario: Matching-number combinations
- **WHEN** 球组包含同数字的二、三、四或五格
- **THEN** 评价器 SHALL 分别能返回对子、三条、炸弹或五球满贯及其参与槽位

#### Scenario: Straight ignores unrelated pollution
- **WHEN** 球组为红 3、蓝 4、黄 5、红 9
- **THEN** 评价器 SHALL 识别 3-4-5 三球顺子，并将红 9 标记为污染球

#### Scenario: Same-color straight
- **WHEN** 球组包含红 3、红 4、红 5 和蓝 9
- **THEN** 评价器 SHALL 识别红色三球同色顺，并仅将前三格标记为参与球

### Requirement: Combination values use a versioned M2 table
M2 组合倍率 SHALL 为：单球 ×1、对子 ×3、三条 ×7、炸弹 ×15、五球满贯 ×30；顺子、同色与同色顺按参与格数分别使用下表：三格 ×5/×5/×12，四格 ×7/×7/×18，五格 ×10/×10/×25。倍率表 SHALL 作为规则版本的一部分记录。

#### Scenario: Four-ball same-color straight value
- **WHEN** 最佳组合为四格同色顺
- **THEN** 组合倍率 SHALL 为 ×18

#### Scenario: Replay uses a declared rule version
- **WHEN** Headless 规则回放加载一个 M2 案例
- **THEN** 输出 SHALL 包含使用的组合规则版本，避免静默调参改变历史期望

### Requirement: Best combination selection is deterministic
系统 SHALL 只选择一个最佳组合。候选组合首先按“参与数字总和 × 组合倍率”的基础得分降序选择；相同基础得分时依次按倍率、参与格数、参与槽位索引的字典序择优。任何未参与最佳组合的槽位 SHALL 标记为污染球。

#### Scenario: A hand contains multiple valid combinations
- **WHEN** 同一球组同时满足多个组合
- **THEN** 系统 SHALL 按确定性择优规则返回唯一最佳组合和稳定的参与槽位集合

#### Scenario: Equal score candidates
- **WHEN** 两个候选组合的基础得分相同
- **THEN** 系统 SHALL 按倍率、参与格数和槽位索引顺序稳定打破平局

### Requirement: Base score preview counts only the best combination
最佳组合的参与数字总和 SHALL 作为结算公式基础，污染球 SHALL 占用槽位但不得直接贡献该数字和。M3 SHALL 在此基础上按有序徽章步骤计算 `(参与数字总和 + 徽章基础分追加) × (组合倍率 + 徽章追加倍率) × 徽章乘算倍率`，同时显示 M2 基础分与 M3 最终分；没有槽位时两者均为零且不可结算。

#### Scenario: Pollution does not enter the base number sum
- **WHEN** 球组为红 3、红 4、红 5、蓝 9且最佳组合为红色同色顺
- **THEN** 基础数字和 SHALL 为 12、组合倍率 SHALL 为 12，蓝 9 不直接计入；只有明确读取污染球的徽章可以在后续步骤产生效果

#### Scenario: Pollution does not score
- **WHEN** 球组为红 3、红 4、红 5、蓝 9且最佳组合为红色同色顺
- **THEN** M2 基础分 SHALL 仍为 `(3+4+5) × 12 = 144`，蓝 9 不直接计分；只有明确读取污染球的徽章可以在后续步骤产生效果

#### Scenario: Single-ball hand
- **WHEN** 球组仅有数字 6 一格且装备的徽章满足触发条件
- **THEN** 基础组合 SHALL 仍为单球、M2 基础分 SHALL 为 6，最终分 SHALL 由相同的有序徽章步骤确定
