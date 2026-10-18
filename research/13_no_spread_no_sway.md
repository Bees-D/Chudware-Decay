# 13 — No Spread & No Sway

**Spec:** "Removes aim-down-sights (ADS) sway and random bullet cone spread."

**Dump evidence**
- Spread is produced inside `Ballistics.GetVelocities(Value, v41, LocalPlayer.UserId, v46, Unit2, v50, v51)`
  (GunShootModule.luau:652) — a seeded set of pellet velocities around the aim direction `Unit2`.
- No explicit `Spread`/`Sway` property exists (grep Spread=0, Sway=0); they are emergent from the
  ballistics velocities and the ADS camera.
- Bullets that matter for server damage are the ones fed to `ShotHit`; the local raycast direction is
  what the module uses (GunShootModule.luau:640-692).

**Trust:** local.

**Implementation (best-effort, client)**
- No-spread: `hookfunction(Ballistics.GetVelocities, orig)` → take the returned velocity table and
  rewrite every pellet velocity to point exactly along the camera `Unit2` at the same magnitude
  (collapse the cone). Capability-guarded.
- No-sway: zero the ADS camera sway by re-asserting the aim CFrame each RenderStepped while ADS, or
  pin camera offset. Sway is a local camera effect.

**UI:** toggles "No Spread", "No Sway".

**Risks / partial**
- Without `hookfunction`, no-spread degrades to aim-assist only (documented). No explicit sway field
  → no-sway is a camera-stabilise approximation, not a config flip.
