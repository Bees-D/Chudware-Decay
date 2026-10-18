# 17 — Spider-Man / High Jump

**Spec:** "Modifies jump physics to scale flat vertical walls or jump significantly higher than
normal."

**Dump evidence**
- Standard Humanoid (classes.luau rig). grep JumpPower ×65, JumpHeight ×84 — the game references
  both, so the Humanoid uses the standard jump API (`UseJumpPower` / `JumpHeight`).
- HRP CFrame client-owned (same basis as [[15_fly_noclip]]).

**Trust:** client-auth (physics), anticheat risk.

**Implementation**
- High Jump: set `Humanoid.UseJumpPower = true; Humanoid.JumpPower = <slider>` (and/or
  `Humanoid.JumpHeight`), restore defaults on toggle-off.
- Spider-Man (wall climb): while a wall is detected in front (short raycast from HRP along LookVector)
  and jump held, nudge HRP CFrame upward each frame (climb speed slider).

**UI:** toggle "High Jump" + power slider; toggle "Spider Climb" + speed slider.

**Risks**
- Big vertical deltas are anticheat-visible; default power modest. Restore original JumpPower/Height
  captured at enable time.
