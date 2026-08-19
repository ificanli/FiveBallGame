## ADDED Requirements

### Requirement: Badge catalog is versioned, complete, and auditable
M3 SHALL 提供恰好 18 枚唯一 ID 的桌边徽章，分属纯净组合、撞库连锁、功能墙冒险三条主打法。每条打法 SHALL 至少包含启动器、核心件、放大器和风险或收尾件；所有徽章 SHALL 声明中文名称、中文说明、触发阶段、读取字段、效果类型和数值。

#### Scenario: Catalog audit runs
- **WHEN** 系统或 CI 加载 M3 徽章配置
- **THEN** SHALL 验证数量为 18、ID 唯一、本地化键存在、效果参数有限且三条打法的角色覆盖完整

#### Scenario: Badge cannot affect a shot
- **WHEN** 某候选徽章只提供无条件固定分数且不改变选球、力度、撞库、连锁、功能墙、保留或爆仓判断
- **THEN** 该徽章 SHALL NOT 计入“改变击球判断”的 70% 验收数量

### Requirement: Run equips at most five ordered badges
Run SHALL 最多装备五枚徽章，并保存稳定的从左到右顺序。奖励选择在空槽时追加；槽满后 SHALL 要求明确替换或放弃，不得静默扩容。

#### Scenario: Player reorders badges
- **WHEN** 玩家在球静止且不处于结算动画时调整徽章顺序
- **THEN** Run 快照 SHALL 保存新顺序，下一次预览与结算 SHALL 使用相同顺序

#### Scenario: Reward arrives with full badge slots
- **WHEN** 玩家已有五枚徽章并选择新徽章
- **THEN** 系统 SHALL 要求选择被替换徽章或取消该奖励，不得产生第六槽

### Requirement: Badge settlement is deterministic and traceable
结算 SHALL 先使用最佳组合参与数字总和与组合倍率，再按徽章从左到右产生可序列化步骤。最终公式 SHALL 为 `(数字总和 + 基础分追加) × (组合倍率 + 追加倍率) × 乘算倍率`。每一步 SHALL 记录徽章 ID、是否触发、读取证据、效果前后值及成长变化。

#### Scenario: Multiple badges trigger
- **WHEN** 一手同时满足多枚徽章
- **THEN** 预览、正式结算、Headless 回放和 UI SHALL 使用相同有序步骤并得到相同整数最终分

#### Scenario: Badge condition is not met
- **WHEN** 某徽章条件不满足
- **THEN** 结算步骤 SHALL 记录未触发且不得修改任一数值

### Requirement: Three build identities change shot decisions
首版 SHALL 提供三条可构筑路径：纯净组合鼓励减少污染并追求顺/同色/同号；撞库连锁鼓励特定力度、有效撞库和间接激活；功能墙冒险鼓励指定球触发复制/染色并管理五槽爆仓风险。至少 13/18 枚徽章 SHALL 读取或改变上述可操作决策，而非只做无条件倍率。

#### Scenario: Counterfactual route comparison
- **WHEN** 同一桌面为三套代表性 Build 生成“直取容易球”和“执行流派路线”两种合法输入
- **THEN** 每套 Build 的流派路线 SHALL 在其声明条件满足时获得不同触发记录，且非对应 Build 不得得到同等触发集合

#### Scenario: Human reviews build recordings
- **WHEN** 真人观看隐藏分数 UI 的三套代表性击球录像
- **THEN** 验收记录 SHALL 判断是否能仅从力度、撞库、连锁和功能墙选择识别 Build；自动代理不得代替该结论

### Requirement: Growth persists only within the current run
成长型徽章 SHALL 将进度保存在 Run 快照中，跨桌保留并在 Run 结束或重开时清零。成长触发 SHALL 来自可验证的规则事件。

#### Scenario: Growth condition completes
- **WHEN** 成长徽章在一桌中满足声明条件
- **THEN** 其进度与等级 SHALL 原子更新，并在下一桌的结算预览中生效

#### Scenario: New run starts
- **WHEN** 玩家结束或放弃当前 Run 并开始新 Run
- **THEN** 所有徽章成长 SHALL 恢复定义初值
