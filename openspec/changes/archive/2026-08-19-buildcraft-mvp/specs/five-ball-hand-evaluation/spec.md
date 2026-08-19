## MODIFIED Requirements

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
