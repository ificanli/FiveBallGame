# shot-input-modes Specification

## Purpose

M3.5 把「移动鼠标瞄准 + 点击发射」的单一操作方式，改为网页版设计稿（`弹射梭哈_核心方案_v0.2.md`）定义的两种出杆方式：**拉杆出手**（按住拖拽、松开击球）与 **精细瞄准**（调向 + 选档 + 点击击球）。两种方式共用同一套五档初速度、物理模拟与辅助线，只改变输入流程，不进入规则层、不改变回放 Hash。

## ADDED Requirements

### Requirement: Two shot modes are switchable anytime and persisted
场景 SHALL 提供拉杆（drag）与精细（fine）两种出杆方式，可随时在场景内切换并立即生效；玩家偏好 SHALL 写入 `user://settings.cfg` 的 `controls/input_mode`，下次启动沿用；默认值为 `drag`。

#### Scenario: Preference survives restart
- **WHEN** 玩家切换到「精细」并重启游戏
- **THEN** 进入技术桌后 SHALL 仍是精细模式

### Requirement: Drag mode aims and fires by press-drag-release
拉杆模式 SHALL 支持：在球桌内按住左键开始拖拽，拖拽方向决定发射角度（弹弓式：向母球反方向拉，松开向拉杆反方向发射）；拖拽距离按最大 260px 映射到 1～5 档并吸附，不保留档间连续值；松开左键出杆；拖拽距离小于最大距离 10% 不出杆并给出中文提示；拖拽期间按右键或 Esc 取消本次瞄准，不出杆、不消耗杆数。

#### Scenario: Drag maps to a fixed discrete power
- **WHEN** 玩家在拉杆模式下以 150px 距离向左拖拽母球并松开
- **THEN** 发射方向 SHALL 向右，且力度 SHALL 是五档之一（3 档），不是档间连续值

#### Scenario: Tiny drag is cancelled
- **WHEN** 玩家拖拽距离小于死区后松开
- **THEN** SHALL 不出杆、不消耗杆数，并显示中文取消提示

### Requirement: Drag mode shows aiming feedback
拉杆模式拖拽期间 SHALL 显示：拖拽线、母球旁当前档位大数字、松手前母球首碰位置的半透明幽灵球（来自预览 `first_event.point`）。

#### Scenario: Ghost ball appears at first contact
- **WHEN** 玩家在拉杆模式拖拽且预览已生成
- **THEN** SHALL 在母球首碰位置绘制半透明幽灵球，并在母球旁显示当前档位数字

### Requirement: Fine mode separates aiming from firing
精细模式 SHALL 支持：移动鼠标或点击球桌调整发射方向且点击不发射；左右微调按钮与键盘 ←/→ 按 0.5° 精修方向；独立选择 1～5 档力度（键盘 1～5 与常驻力度条）；点击「击球」按钮或按 Space/Enter 确认出杆；调整方向与力度期间 SHALL NOT 误发射。

#### Scenario: Clicking the table only re-aims
- **WHEN** 玩家在精细模式点击球桌上某点
- **THEN** 母球 SHALL 朝该方向瞄准，且 SHALL NOT 出杆

### Requirement: Both modes share rules, physics, assist and copy
两模式 SHALL 生成完全相同的 `ShotInput`（五档离散力度 + 归一化方向）；物理、组合、徽章、回放与 Hash SHALL NOT 受输入方式影响；辅助线三档（简洁/标准/完整）SHALL 在两种模式下行为一致；中文文案 SHALL 覆盖两模式操作提示（`feedback.drag_ready` / `feedback.fine_ready` / `feedback.drag_cancelled`、`controls.drag` / `controls.fine`）。

#### Scenario: Rule replay hash is mode-independent
- **WHEN** 相同 `ShotInput`（同方向、同档位）分别在拉杆与精细模式下发射
- **THEN** 回放结果与状态 Hash SHALL 完全一致

## DELETED Requirements

- ~~鼠标瞄准时左键点击球桌任意位置即发射~~（原 `technical_table.gd` 的 `_handle_click` 直接出杆行为被两种模式取代；左键点击在精细模式只调整方向，在拉杆模式只开始拖拽）。

## Non-Requirements

- 不新增手柄/触屏输入；拉杆手势仅映射到鼠标。
- 拖拽距离连续变化仅用于档位吸附，不引入新的力度维度。
- 不改变五档初速度数值（330/495/660/858/1100）。
