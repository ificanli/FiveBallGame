# M1 human QA checklist

Build branch: `feature/deterministic-physics-table`  
Machine status: `PASS_ENGINEERING`  
Human status: pending

## Launch

Run:

`builds/windows/FiveBallGrandSlam.exe`

Expected first screen: dark green technical table, one white cue ball, six colored number balls, copy/dye walls, predicted paths, and a debug panel.

## Controls

- Move mouse: aim
- Left click or Space/Enter: shoot
- `1`–`5`: fixed power
- `Tab`: concise → standard → full assistance
- `←` / `→`: fine aim by 0.5°
- `R`: reset the same Seed

## Required checks

### A. Basic visibility and input

- [ ] Window opens at 1365×768 without clipping.
- [ ] Mouse movement updates aim immediately.
- [ ] Keys 1–5 visibly change power.
- [ ] Tab cycles all three assistance modes.
- [ ] R restores the identical ball/wall layout.

### B. Prediction and repetition

- [ ] Predicted first contact matches the actual first contact.
- [ ] Repeat the same shot after R at least three times; the visible route is repeatable.
- [ ] Concise is readable, standard is useful, full is not an unreadable spaghetti mess.

### C. Wall causality

- [ ] Route an activated number ball to COPY; feedback names the actual ball and the charge becomes empty.
- [ ] Route an activated number ball to DYE; that physical ball changes color and keeps its number.
- [ ] Cue-ball contact with a function wall does not trigger copy/dye.
- [ ] In a chain, the triggering ball is visually attributable; no “latest ball” ambiguity.

### D. Feel comparison

Compare against `docs/WEB_PROTOTYPE_PHYSICS_REFERENCE.md` and answer:

- Control reliability: better / equal / worse than web
- Bounce intuition: better / equal / worse
- Stopping rhythm: better / equal / worse
- Chain readability: better / equal / worse
- Five power levels: distinct and memorable / need tuning
- Six-second maximum-duration finish: acceptable / too slow / feels cut off

## Decision format

```text
版本/commit：
A 基础输入：通过 / 问题
B 预测复现：通过 / 问题
C 墙体归属：通过 / 问题
控制可靠性：更好 / 相当 / 更差
反弹直觉：更好 / 相当 / 更差
收杆节奏：更好 / 相当 / 更差
连锁可读性：更好 / 相当 / 更差
总体：通过 M1 / 需要调参 / 结构性失败
备注：
```

Passing this checklist does not claim the full game is fun; it only closes the M1 physics/feel gate.
