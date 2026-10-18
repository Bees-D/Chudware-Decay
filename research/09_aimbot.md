# 09 — Aimbot

**Spec:** "Automatically snaps or locks the player's crosshair onto designated hitboxes
(Head, Chest, Spine)."

**Dump evidence**
- Shot declaration carries the aim vector the server uses:
  `Shot:FireServer({ShotId, CameraOrigin, CameraDirection, MuzzleOrigin, Slot, ClientTime, FirstShot})`
  (GunShootModule.luau:641-649).
- The local bullet raycast uses the same camera ray (`ViewportPointToRay` center,
  GunShootModule.luau:569-573); when it hits a character part the module auto-fires `ShotHit`
  (GunShootModule.luau:391-400,545).
- Target parts exist on the standard rig: `Head`, torso parts (classification by name).

**Trust:** client-auth. Two coherent approaches, both grounded:
1. **Camera-snap aimbot:** before/while firing, rotate `workspace.CurrentCamera.CFrame` to look at
   the chosen hitbox. The game's own ray then points at the target, `Shot.CameraDirection` and the
   local raycast both agree, and `ShotHit` fires naturally. Server sees a consistent shot.
2. If silent (no camera move) is wanted, that is [[12_silent_aim]] (ShotHit injection).

**Implementation**
- Target selection: nearest-to-crosshair or nearest-by-distance among valid enemies (visible check
  optional via raycast). Hitbox = Head / UpperTorso|Torso (Chest) / LowerTorso (Spine), resolved by
  `FindFirstChild` with fallback.
- On RenderStepped while aim key held (or always-on toggle), set camera CFrame =
  `CFrame.lookAt(camPos, targetPartPos)` (optionally smoothed — see [[10_smoothing]]).
- FOV gate (only lock within N px), team check (skip same `CustomTeam.Value`).

**UI:** toggle, keybind (hold/toggle), hitbox dropdown, FOV slider, team-check, visible-check.

**Risks**
- Server may re-validate ShotHit `Part`/`Position` against `Shot.CameraDirection`; camera-snap keeps
  them consistent (lower risk than pure silent aim).
- Reading a dying target's parts → pcall, drop target if HRP nil.
