# Web prototype physics reference shots

Status: M1 comparison input; read-only source audit  
Recorded: 2026-08-17

## Source drift

The planned path `E:/NewGame-prototypes/ricochet` no longer exists. The complete historical source currently found at:

`E:/NewGame-prototypes/0废弃文件/ricochet`

was read without modification. `E:/NewGame/test-artifacts/ricochet-current` contains screenshots/logs only and is not a source tree. This path drift must not be interpreted as permission to resume development in the archived HTML project.

## Extracted constants

From `js/physics.js` and `js/game.js`:

- fixed step: `1/120s`
- visual base radius: physics constant `18`; number-ball render radius `19`
- collision skin: `1.5`
- ball restitution: `0.95`
- rail/wall restitution: `0.9`
- drag: `pow(0.992, 60/120)` per 120 Hz step
- five speeds: `330 / 495 / 660 / 858 / 1100`
- canvas: `1000 × 620`
- cue default: `(130, 315)`
- prediction: same `Physics.step`, standard about `2.2s`, full about `4s`

These are reference values, not frozen Godot values. The web code uses overlap-first discrete collision and frame accumulation; M1 may change absolute tuning while preserving or improving learnability.

## Controlled reference shots

Set the listed objects manually in a read-only copy or an isolated fixture. All coordinates use the web canvas coordinate system. Empty rows mean no unrelated balls near the path.

| ID | Initial layout | Input | Expected machine observation | Human review question |
|---|---|---|---|---|
| WEB-01 | cue `(130,315)`, red-3 `(430,315)` | level 3, angle `0°` | first contact red-3, near head-on transfer | Does a standard direct hit feel decisive rather than mushy? |
| WEB-02 | cue `(130,315)`, blue-5 `(430,345)` | level 3, angle `0°` | glancing first contact; both balls retain visible motion | Is the cut angle intuitive from the visible circles? |
| WEB-03 | cue `(130,315)`, no target before right rail | level 2, angle `-28°` | top/right rail route, energy loss after rail | Does one-bank aiming feel learnable and not overly dead? |
| WEB-04 | cue `(130,315)`, red-3 `(350,315)`, blue-4 `(540,315)` | level 4, angle `0°` | ordered cue→red-3→blue-4 chain | Is the two-ball chain readable and satisfying? |
| WEB-05 | cue `(130,315)`, yellow-7 `(320,315)`, copy wall centered around `(560,285)` | level 4, angle `0°` | yellow-7 becomes active then reaches copy wall | Can the player attribute the wall trigger to yellow-7? |
| WEB-06 | cue `(130,315)`, blue-5 `(320,315)`, red dye wall centered around `(560,285)` | level 4, angle `0°` | blue-5 reaches dye wall and becomes red without changing number | Is the entity/color change visible during motion? |
| WEB-07 | cue `(130,315)`, red-3 `(310,315)`, blue-5 `(480,350)`, dye wall beyond blue-5 | level 5, angle `0°` | indirect activation may propagate red-3→blue-5→wall | Is the indirect chain controllable or merely chaotic? |
| WEB-08 | cue `(130,315)`, target `(430,315)` | repeat levels 1–5, angle `0°` | monotonically increasing travel/impact; exact five speeds above | Are adjacent levels distinct yet memorizable? |
| WEB-09 | cue `(130,315)`, target `(430,315)` | repeat level 3 five times | same first contact and near-identical stop state | Does repetition build trust? |
| WEB-10 | cue `(130,315)`, sparse table | level 1, angle `12°` | low-speed tail stops without prolonged crawling | Does the shot end promptly without feeling cut off? |

## Comparison record template

For each shot record separately:

- build commit and physics version;
- actual first contact and ordered event summary;
- ticks and stop reason;
- final normalized state/hash;
- web observation;
- Godot observation;
- author rating for control reliability, bounce intuition, stopping rhythm, chain readability;
- decision: pass / tune / structural failure / no conclusion.

Machine agreement cannot answer the human-review questions.
