# 16 — Omni-Sprint / Always Sprint

**Spec:** "Allows full-speed sprinting in any direction (backward, sideways) or while performing
actions like healing or reloading."

**Dump evidence**
- WalkSpeed is set directly client-side: `Humanoid2.WalkSpeed = 16.5` (sprint), `12` (walk), `8`
  (crouch) (Sprint.luau:206,229,372).
- Vanilla sprint is gated by `CanSprint()` which requires forward movement
  (`MoveDirection:Dot(LookVector) > 0.5`), water > 0, inventory closed, and WalkSpeed ∈ {12,16.5}
  (Sprint.luau:161-184).
- `player.IsSprinting` BoolValue tracks state (Sprint.luau:228).

**Trust:** client-auth (WalkSpeed is client-owned; server anticheat may cap).

**Implementation**
- Each RenderStepped (or Humanoid.WalkSpeed change hook), if enabled, force
  `Humanoid.WalkSpeed = max(current, sprintSpeed)` regardless of move direction — defeats the
  forward-only `CanSprint` gate (omni-directional). Optional custom speed slider (default 16.5 to
  stay near-legit; higher = more risk).

**UI:** toggle "Always Sprint", speed slider (16.5 default).

**Risks**
- Setting WalkSpeed well above 16.5 is the obvious anticheat trip; default to the game's own sprint
  value and let the user opt into higher. Re-assert because the game resets WalkSpeed on many events.
