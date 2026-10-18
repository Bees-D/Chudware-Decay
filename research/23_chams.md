# 23 — Chams

**Spec:** "Replaces player/object models with bright neon textures that shine through walls or pitch
darkness."

**Dump evidence**
- The game itself uses `Highlight` instances on interactables (`Unified.luau:12,60-61` sets
  `FillTransparency`/`OutlineTransparency`; PickUpClient tweens them) — so `Highlight` with
  `DepthMode = AlwaysOnTop` is native-compatible and the cleanest cham.
- Player targets from [[02_player_sleeper_esp]].

**Trust:** local.

**Implementation**
- For each enemy/target character, create (and cache) a `Highlight` parented to the character with
  `FillColor`/`OutlineColor` from team logic, `FillTransparency` low, `DepthMode =
  Enum.HighlightDepthMode.AlwaysOnTop`. Remove highlight when the character leaves.
- Reuse the ESP player list; share a per-character highlight registry.

**UI:** toggle "Chams", fill color, outline color, fill transparency slider, team-color toggle.

**Risks**
- Creating highlights on dying characters → pcall + parent-exists check; clean up on removal to avoid
  leaks.
