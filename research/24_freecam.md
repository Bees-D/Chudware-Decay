# 24 — Debug Camera / Freecam

**Spec:** "Unlocks the camera from the player model, allowing users to scout inside enemy bases or
inspect surroundings without moving physically."

**Dump evidence**
- `workspace.CurrentCamera` is referenced throughout and is client-owned (GunShootModule.luau:48,
  Sprint.luau tweens FieldOfView/CFrame). The game's own `CameraModule` sets
  `Camera.CameraType`/CFrame (classes.luau BaseCamera), so taking Scriptable control is consistent.

**Trust:** local.

**Implementation**
- On toggle: save current `Camera.CameraType`/CFrame, set `CameraType = Enum.CameraType.Scriptable`,
  and each RenderStepped move `Camera.CFrame` from WASD + mouse-delta (speed slider). The character
  stays put (do not move HRP).
- On toggle-off: restore `CameraType` and let CameraModule resume (set subject back to Humanoid).

**UI:** toggle "Freecam", speed slider, keybind.

**Risks**
- The game's CameraModule may contest Scriptable mode → re-assert `CameraType = Scriptable` each
  frame while active. Restore cleanly to avoid a stuck camera.
