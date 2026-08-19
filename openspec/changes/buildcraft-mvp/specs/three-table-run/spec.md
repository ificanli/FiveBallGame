## ADDED Requirements

### Requirement: M3 Run has exactly three escalating tables
短 Run SHALL 依次包含资格桌、高额桌和庄家桌三张版本化配置。每桌 SHALL 声明固定 Seed 派生方式、布局、球池、功能墙、目标分、杆数和补球目标；难度 SHALL 通过目标、球量、路线与公开规则递进，而非隐藏惩罚。

#### Scenario: New run starts
- **WHEN** 玩家用一个 Run Seed 开始 M3 Run
- **THEN** 系统 SHALL 先进入开局徽章三选一，再加载资格桌且三桌配置顺序固定

#### Scenario: Player reaches table target
- **WHEN** 一次结算使本桌累计分达到目标
- **THEN** 本桌 SHALL 立即胜利并停止额外出杆刷分，超额分只进入统计而不带入下桌

### Requirement: Reward choices build at least a three-badge identity
开局、资格桌胜利后和高额桌胜利后 SHALL 各出现一次徽章三选一。候选 SHALL 由 Run Seed、奖励序号、当前 Build 与版本化池确定；同一组内 ID 不重复。开局池只含三条流派启动器，后续至少包含一项与当前 Build 联动的候选，且不得保证唯一最优答案。

#### Scenario: Same reward state is generated again
- **WHEN** 相同 Run 快照生成同一奖励序号
- **THEN** 三个候选及其顺序 SHALL 相同，关闭重开界面不得刷新候选

#### Scenario: Player enters dealer table
- **WHEN** 玩家完成前两次桌后奖励
- **THEN** SHALL 已有机会装备至少三枚徽章并形成可识别的主流派或混合 Build

### Requirement: Run state is serializable and independent of presentation
`RunSnapshot` SHALL 保存版本、Seed、随机流计数、当前桌索引、徽章顺序与成长、道具、奖励状态、桌快照、累计统计和终态；不得保存 Godot 节点引用或本地化后的显示文本。

#### Scenario: Run snapshot round-trips
- **WHEN** Run 快照序列化后重新加载
- **THEN** 规范化数据、合法动作、奖励、下一次补球和状态 Hash SHALL 与加载前相同

### Requirement: Run has explicit victory, failure, abandon, and restart
庄家桌达标 SHALL 完成 Run；任一桌杆数耗尽且未达标 SHALL 失败。胜负界面 SHALL 显示三桌结果、Build、关键触发与总时长，并允许相同 Seed 重开或新 Seed 开始。放弃 SHALL 需要确认且不得伪装为失败统计。

#### Scenario: Dealer table is cleared
- **WHEN** 玩家在庄家桌达到目标
- **THEN** Run SHALL 进入胜利终态并禁止继续出杆或领取不存在的第四次桌后奖励

#### Scenario: A table is lost
- **WHEN** 最后结算机会结束且本桌低于目标
- **THEN** Run SHALL 进入失败终态并保留可导出的失败证据

### Requirement: Human acceptance validates a 15–25 minute arc
M3 候选 SHALL 经过真人从实际导出包完成至少一局 Run，并记录总时长、三选一理解、三套 Build 可辨识性、是否因徽章改变球路、道具是否替代出杆及阻塞问题。自动代理不得证明“好玩”。

#### Scenario: Human completes M3 review
- **WHEN** 真人完成或失败一局候选 Run
- **THEN** 记录 SHALL 给出 PASS、REVISE 或 NO CONCLUSION，并明确实际时长是否落在 15～25 分钟目标区间
