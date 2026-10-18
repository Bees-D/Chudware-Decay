# 11 — Target Prediction

**Spec:** "Automatically calculates bullet drop, projectile velocity, and target velocity to lead
shots with bows, firearms, or rockets."

**Dump evidence**
- Ballistics module exposes the projectile model: `Ballistics = require(ReplicatedStorage.GunSystem.Ballistics)`
  with `.GetConfig(Value, itemData)` → `{Gravity, MaxTime, HitRadius}` and `.GetVelocities(...)`,
  `.Position(origin, velocity, gravity, t)`, `.Step(...)` (GunShootModule.luau:17,286,294,340,637,652).
- Bullet drop/velocity are therefore knowable client-side from the gun's config.
- Target velocity: `HumanoidRootPart.AssemblyLinearVelocity` (standard, rig confirmed).

**Trust:** local (computes an aim point; firing still goes through the normal Shot/ShotHit path).

**Implementation**
- For the selected target, estimate time-to-hit `t ≈ distance / muzzleSpeed` (muzzleSpeed derived
  from `Ballistics.GetVelocities` magnitude or gun ItemData), then lead point =
  `targetPos + targetVel * t`, plus gravity-drop compensation `+ 0.5*Gravity*t^2` upward on aim.
- Feed the predicted point to the aimbot ([[09_aimbot]]) instead of the raw part position.

**UI:** toggle "Target Prediction", strength/lead-scale slider.

**Risks / partial**
- `GetVelocities` is seeded per shot; exact muzzle speed is approximated from config, so prediction
  is best-effort, not frame-perfect. Documented as approximate in BUILD_REPORT.
- Rockets: `Value == "Rocket Launcher"` skips the local raycast branch (GunShootModule.luau:651) —
  rocket prediction is aim-assist only, no ShotHit lead.
