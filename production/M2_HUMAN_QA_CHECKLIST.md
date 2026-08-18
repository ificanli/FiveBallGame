# M2 Human QA Checklist

Candidate: `builds/windows/FiveBallGrandSlam.exe`  
Required session: at least 15 continuous minutes from the exported build.  
Automation cannot sign this gate.

## Controls

- Mouse: aim
- Left click / Space: shoot
- 1–5: power
- Tab: preview mode
- S or SETTLE: bank shown score
- K or KEEP: preserve hand for another shot
- R or RESET button: same tutorial setup

## Required observations

- [ ] First cue/chain contact visibly adds the correct numbered/color ball to one slot.
- [ ] Gold-ring hand balls remain on table and cannot enter a second slot; dim waste balls still collide but cannot collect or trigger walls.
- [ ] Copy wall adds a `COPY` slot without spawning a physical ball; dye changes the actual impacting ball and its linked physical slot only.
- [ ] Best-combo name, highlighted participant slots, dim pollution slots, and `sum × multiplier = score` agree with the visible hand.
- [ ] SETTLE banks exactly the previewed score, clears the hand, and converts physical hand balls to waste.
- [ ] KEEP preserves slots and score, returns to aiming, and the next valid launch consumes one stroke.
- [ ] Acquiring a sixth physical/copy slot shows BUST, clears the hand, preserves banked score, and lets remaining balls finish moving.
- [ ] At zero strokes a final hand can settle but cannot keep; target produces WIN, below-target produces LOSS.
- [ ] Win/loss blocks further shots; reset restores the exact same score, strokes, balls, states, walls, and Seed.
- [ ] Complete at least one settle, keep-then-shoot, copy or dye, bust, terminal result, and reset during the session.
- [ ] No input deadlock, invisible decision, stuck motion, crash, or blocking visual overlap occurs for 15 minutes.

## Human record

- Date/time:
- Candidate commit:
- Session duration:
- Completed required paths:
- Most confusing rule:
- Was bust foreseeable?:
- Wall ownership understandable?:
- Blocking bugs:
- Verdict: PASS / REVISE / NO CONCLUSION
