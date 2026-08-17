# 《五球满贯》PvP 技术架构 v0.1

更新时间：2026-08-17
状态：架构讨论稿
目标引擎：Godot 4.x
目标模式：共享碰撞球桌、双方轮流出杆

---

# 一、架构结论

推荐采用：

> **房主权威（Host Authoritative）+ 回合制输入同步 + 杆后权威快照 + 输入回放。**

不采用：

- 每帧同步所有球的位置；
- 纯客户端信任；
- 首版专用服务器；
- 实时帧同步；
- 格斗游戏式回滚网络；
- 依赖跨平台浮点完全一致的纯 Lockstep。

原因：

- PvP 是轮流出杆，不是双方同时实时操作；
- 每杆开始前桌面静止，天然存在稳定同步点；
- 一杆只需发送少量输入；
- 房主可以完整模拟物理与规则；
- 一杆结束后可以发送最终快照纠偏；
- 网络延迟只影响确认，不会持续破坏操作手感；
- 首版可以通过 Steam P2P Relay 连接，不需要维护服务器。

---

# 二、分阶段开发

## 阶段 A：本地热座 PvP

先在同一进程中验证玩法：

```text
玩家 A 出杆
→ 本地规则模拟
→ 杆后决策
→ 玩家 B 出杆
```

目标：

- 验证抢球是否有趣；
- 验证结算 / 保留是否纠结；
- 验证等待回合是否可接受；
- 验证固定 8 杆时长与先手优势；
- 验证 PvP 状态机。

此阶段完全不写联网逻辑，但规则层必须从一开始支持序列化。

## 阶段 B：局域网 / 开发网络版

使用 Godot ENet 或 WebSocket 做房主权威原型。

目标：

- 验证输入消息、快照和重连；
- 模拟延迟、丢包和断线；
- 验证一杆回放一致性；
- 不接 Steam Lobby。

## 阶段 C：Steam P2P

使用 GodotSteam / Steam Multiplayer Peer 或 Steam Networking Sockets：

```text
Steam Lobby
→ 房主创建对局
→ Steam Relay 建立 P2P
→ 房主权威模拟
→ 客户端观看和提交出杆
```

目标：

- 邀请好友；
- 大厅匹配；
- NAT 穿透与 Steam Relay；
- 断线重连；
- 对局结果上报。

## 阶段 D：排位与赛事（1.0 后再决定）

若确实需要排位、公平竞技或奖金赛事，再考虑：

- 权威专用服务器；
- 云端复算每杆；
- 对局签名；
- 反作弊；
- 赛季与匹配分。

首发阶段不要提前承担此成本。

---

# 三、权威模型

## 房主负责

- 创建初始 Seed；
- 生成球桌；
- 保存唯一权威 `MatchState`；
- 验证行动方与输入是否合法；
- 执行完整物理模拟；
- 处理碰撞事件；
- 处理抢球、功能墙、组合、爆仓；
- 处理结算 / 保留；
- 推进行动方和剩余杆数；
- 发送杆后快照；
- 判定胜负。

## 客户端负责

- 本地渲染权威状态；
- 瞄准、力度与母球放置预览；
- 在自己的回合提交 `ShotCommand`；
- 播放房主返回的权威击球；
- 校验状态 Hash；
- 发生差异时应用权威快照；
- 非行动回合观察桌面与对方球组。

## 客户端不负责

- 自行决定抢球结果；
- 自行决定组合分数；
- 自行扣除杆数；
- 自行改变球归属；
- 自行判定胜负。

---

# 四、对局状态

建议核心状态：

```gdscript
class_name MatchState

var match_id: String
var protocol_version: int
var content_version: String
var seed: int
var turn_index: int
var active_player: int
var phase: int
var players: Array[PlayerState]
var table: TableState
var pending_decision: DecisionState
var winner: int
```

## PlayerState

```gdscript
var player_id: String
var score: int
var shots_left: int
var hand_ball_ids: Array[int]
var best_combo: ComboResult
var has_committed_decision: bool
var connected: bool
```

## TableState

```gdscript
var balls: Array[BallState]
var walls: Array[WallState]
var cue_spawn_zone: Rect2
var wall_charge_state: Dictionary
var state_revision: int
```

## BallState

```gdscript
var id: int
var kind: int          # cue / number
var number: int
var color_id: int
var position: Vector2
var velocity: Vector2
var owner: int         # neutral / player A / player B
var collection_state: int
var active_chain_id: int
var pocketed: bool
```

规则真相必须存在于这些纯数据结构中，而不是分散在场景节点和动画对象里。

---

# 五、PvP 状态机

```text
LOBBY
→ MATCH_LOADING
→ TURN_AIM
→ SHOT_PENDING
→ SHOT_PLAYING
→ SHOT_RESOLVING
→ DECISION_PENDING
→ TURN_SWITCH
→ TURN_AIM
→ MATCH_RESULT
```

## TURN_AIM

- 只有行动方可提交输入；
- 非行动方可查看球桌、球组与预测信息；
- 房主验证母球位置、方向与力度。

## SHOT_PENDING

- 房主收到 `ShotCommand`；
- 验证后生成 `ShotAccepted`；
- 双方统一从同一个权威状态开始播放。

## SHOT_PLAYING

- 房主运行权威模拟；
- 客户端可根据同一输入本地预测播放；
- 房主持续记录碰撞事件，但不需要每帧广播位置。

## SHOT_RESOLVING

- 所有球进入停止状态；
- 房主统一处理收球、抢球、墙体效果、爆仓和组合；
- 发送 `ShotResult` 和状态 Hash。

## DECISION_PENDING

行动方选择：

- 立即结算；
- 保留球组。

房主处理后发送 `DecisionResult`。

## TURN_SWITCH

- 切换行动方；
- 恢复墙体充能；
- 重置 / 摆放母球；
- 更新回合与杆数；
- 进入下一回合。

---

# 六、网络消息

建议所有消息带：

```text
protocol_version
match_id
state_revision
sender_id
sequence
```

## 客户端 → 房主

### ReadyCommand

准备状态。

### PlaceCueCommand

```text
position
```

### ShotCommand

```text
cue_position
angle_quantized
power_level        # 1～5
optional_spin      # MVP 暂不启用
client_state_hash
input_sequence
```

方向建议量化，例如 `0～65535` 映射完整角度，避免直接传任意浮点。

### HandDecisionCommand

```text
SETTLE | HOLD
```

### ReconnectRequest

```text
match_id
player_token
last_revision
```

## 房主 → 双方

### MatchSnapshot

完整权威状态，开局、重连和纠偏时使用。

### ShotAccepted

```text
shot_id
initial_state_hash
accepted_input
start_tick
```

### ShotResult

```text
shot_id
collision_events
collection_events
wall_events
final_state_hash
final_snapshot
```

MVP 可以每杆都附完整最终快照。数据量很小，没必要过早做增量优化。

### DecisionResult

```text
player_id
choice
score_delta
released_ball_ids
next_player
```

### MatchResult

```text
winner
scores
match_statistics
replay_digest
```

---

# 七、物理同步策略

## 不推荐纯帧同步

即使使用固定步长，不同平台、编译器与浮点实现仍可能在多球连续碰撞后积累误差。

如果完全依赖：

```text
相同输入
→ 双方各自模拟
→ 永远得到完全相同结果
```

一旦漂移，抢球归属和组合可能直接不同。

## 推荐：输入回放 + 房主最终快照

流程：

```text
房主广播权威初态与 ShotCommand
→ 双方本地播放
→ 房主完成权威模拟
→ 广播碰撞事件、最终 Hash 与最终快照
→ 客户端校验
→ 有差异时在动画结束点纠偏
```

优点：

- 画面流畅；
- 网络数据少；
- 不要求逐帧位置同步；
- 杆后一定回到一致状态；
- 便于保存回放与复现 Bug。

## 什么时候需要中途同步

一般不需要。

只有以下情况才发送中间关键帧：

- 一杆持续时间异常超过阈值；
- 低速球长时间不停止；
- 动态机关在一杆中改变几何；
- 客户端状态 Hash 提前失配；
- 观战者中途加入。

MVP 功能墙不移动，因此杆后同步足够。

---

# 八、客户端预测与纠偏

## 行动方

- 本地瞄准完全即时；
- 辅助线由本地规则层计算；
- 点击出杆后可以先播放拉杆动画；
- 收到 `ShotAccepted` 后启动球体模拟；
- 不在未确认前修改分数和归属。

## 非行动方

- 收到 `ShotAccepted` 后播放相同模拟；
- 可以显示对方瞄准线，也可只在出杆后显示球路；
- 不需要同步对方每个鼠标移动，降低带宽与心理战信息泄漏。

## 纠偏表现

若最终位置有微小误差：

- 在球全部停止后，用 100～200ms 平滑吸附到权威位置；
- UI 归属、球组和分数直接采用权威结果；
- 不在运动中瞬移球体。

若差异很大：

- 停止本地播放；
- 应用权威快照；
- 记录 Divergence 日志；
- 提示“桌面已同步”，但不向普通玩家展示技术细节。

---

# 九、断线与重连

## 短暂断线

- 房主保留房间 60～120 秒；
- 对局暂停；
- 客户端重连后申请完整快照；
- 从最近的静止回合节点恢复。

## 出杆过程中断线

- 房主继续完成权威模拟；
- 保存杆后快照；
- 重连后从杆后决策阶段恢复；
- 不尝试恢复到半杆动画中间。

## 房主断线

MVP：

- 对局结束或判定无结果；
- 不做 Host Migration。

正式版若直接 PvP 通过，再评估：

- 房主迁移；
- 中继裁判；
- 权威服务器。

首版不要被 Host Migration 拖死。

---

# 十、反作弊与公平性

## 好友休闲对战

房主权威已足够。

## 房主可作弊的问题

P2P 房主理论上可以修改：

- 球桌初态；
- 物理结果；
- 分数；
- 抢球归属。

所以房主权威不适合高价值排位或赛事。

## 若未来需要排位

推荐两种路线：

### 方案 A：云端逐杆复算

- 房主上传初态、Seed 和 ShotCommand；
- 无图形服务器快速模拟；
- 对比分数和最终 Hash；
- 成本低于全程实时服务器。

由于游戏是轮流出杆，这种方式很适合。

### 方案 B：专用权威服务器

- 服务器维护完整 MatchState；
- 客户端只提交输入；
- 最公平，但成本更高。

只有 PvP 数据证明值得长期运营后才做。

---

# 十一、回放系统

PvP 从第一版开始就应支持回放数据：

```text
协议版本
内容版本
初始 Seed
初始 MatchSnapshot
每个 ShotCommand
每个 HandDecisionCommand
每杆最终 Hash
```

用途：

- 复现不同步；
- 生成精彩一杆回放；
- 举报与审查；
- 幽灵竞分；
- 赛事录像；
- 自动回归测试。

不要录视频作为唯一回放。输入日志才是规则证据。

---

# 十二、等待回合的体验设计

技术上轮流很简单，体验上等待可能是最大问题。

非行动方可以：

- 查看自己与对方球组；
- 标记关键球；
- 查看球体归属；
- 预览自己下杆可能的球路，但不能提交；
- 查看对方当前组合威胁；
- 使用表情 / 快捷交流；
- 在对方杆结束前提前选择建议策略。

首版不要允许非行动方使用道具或移动机关，避免变成实时打断。

目标：对方行动时仍然有读局价值，但不增加同步复杂度。

---

# 十三、PvP MVP 代码边界

建议模块：

```text
src/pvp/
  pvp_match_state.gd
  pvp_rules.gd
  pvp_turn_controller.gd
  pvp_message_codec.gd
  pvp_replay.gd
  pvp_ai.gd
  pvp_stats.gd

src/network/
  network_transport.gd
  local_transport.gd
  enet_transport.gd
  steam_transport.gd
  snapshot_sync.gd
```

规则层不得直接调用 Steam API。

通过 `NetworkTransport` 抽象：

```gdscript
signal message_received(peer_id, payload)
func host_lobby()
func join_lobby(lobby_id)
func send_reliable(peer_id, payload)
func broadcast_reliable(payload)
func disconnect()
```

本地热座、ENet 和 Steam P2P 使用同一套对局控制器。

---

# 十四、测试计划

## 规则测试

- 中立球首次收取；
- 对手暂存球被抢；
- 原球组同步移除；
- 结算后实体球恢复中立；
- 爆仓后所有暂存球释放；
- 固定 8 杆公平切换；
- 最后一手结算；
- 平局加赛；
- 功能墙归属；
- 复制球归属；
- 染色同步实体与球组。

## 网络测试

- 重复消息；
- 乱序消息；
- 旧 revision 消息；
- 出杆重复提交；
- 非行动方非法提交；
- 杆中断线；
- 决策阶段断线；
- 快照恢复；
- 状态 Hash 不一致；
- 模拟 50～300ms 延迟；
- 模拟 1%～10% 丢包。

## 长跑

- AI 对 AI 1000 局规则稳定性；
- 固定 Seed 重放一致；
- 每局无死锁；
- 平均时长；
- 先手胜率；
- 立即结算率；
- 抢球率；
- 爆仓率。

机器人只能测试规则和数值分布，不能证明 PvP 好玩。

---

# 十五、推荐开发顺序

```text
1. 本地热座 PvP 状态机
2. 简单 AI
3. 回放与状态 Hash
4. LocalTransport 抽象
5. ENet 双进程测试
6. 延迟、断线与快照恢复
7. 真人本地对战验证
8. 真人网络对战验证
9. PvP 通过后接 Steam Lobby / P2P Relay
10. 1.0 后再决定排位服务器
```

不要一开始先接 Steam API。否则玩法没证明，先花一周调大厅和头像，属于典型工程自嗨。

---

# 十六、通过标准

## 技术通过

- 双方每杆后状态一致；
- 200ms 延迟下可正常完成对局；
- 杆中断线可从下一静止节点恢复；
- 回放能复现所有规则结果；
- 1000 局 AI 长跑无状态死锁；
- Windows / Linux 固定输入的权威最终结果可校验。

## 体验通过

- 玩家会主动抢对手关键球；
- 玩家会因怕被抢而提前结算；
- 非行动方会读局而不是离开视线；
- 被抢后产生反击计划，不是只觉得劳动成果被删除；
- 一局优先控制在 8～15 分钟；
- 玩家愿意立即再战；
- 不依赖徽章和道具，基础对抗已经成立。

体验未通过时，不允许用联网、排位、赛季或大量 PvP 徽章硬救。
