# 03 — Skeleton ESP

**Spec:** "Draws a simplified stick-figure skeleton over character models to show body
orientation behind solid objects."

**Dump evidence**
- Standard Roblox rig confirmed (classes.luau: BaseCamera.GetHumanoidRootPart, Animate script,
  Humanoid). Characters are R6/R15 part hierarchies in `workspace[name]`.
- Same player enumeration as [[02_player_sleeper_esp]].

**Trust:** local (Drawing lines, no server interaction).

**Implementation**
- For each target character, connect joints by projecting part positions with
  `Camera:WorldToViewportPoint`. Use a joint table that degrades gracefully:
  R15 (UpperTorso/LowerTorso/Head/limb segments) else R6 (Torso/Head/arms/legs).
  Resolve by `FindFirstChild` and skip missing joints.
- One `Drawing.new("Line")` per bone, updated each RenderStepped; hidden when off-screen or
  `WorldToViewportPoint` Z ≤ 0.

**UI:** toggle "Skeleton ESP", color, thickness, max-distance.

**Risks**
- Rig variant differences → look parts up by name, never assume a fixed set.
- Destroyed character parts → pcall + nil checks.
