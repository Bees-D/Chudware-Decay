# 14 — Thick Bullets / Extended Hitboxes

**Spec:** "Artificially enlarges projectile or target hitboxes so shots register even when missing
slightly."

**Dump evidence**
- The local bullet cast already supports a radius: `MakeCast`/per-bullet `Cast` uses
  `workspace:Spherecast(p16, p15.Radius, p17, p15.Params)` when `Radius > 0`, else `Raycast`
  (GunShootModule.luau:321-330, 678-685).
- Radius comes from `v50.HitRadius` via `Ballistics.GetConfig` (GunShootModule.luau:637,671;
  grep HitRadius ×2). The bullet table field is `Radius` (GunShootModule.luau:672).
- Hits still flow through client-authored `ShotHit` ([[12_silent_aim]]).

**Trust:** client-auth (via the enlarged local cast feeding ShotHit).

**Implementation**
- Option A (grounded, minimal): `hookfunction(Ballistics.GetConfig, orig)` → bump the returned
  `HitRadius` by a slider factor so the module's own spherecast is fatter; the module then registers
  near-misses and fires ShotHit for them. Capability-guarded.
- Option B (target hitbox): temporarily upsize a target part's size for the local cast — rejected,
  too invasive/visible; prefer A.

**UI:** toggle "Thick Bullets" + radius-multiplier slider.

**Risks**
- Needs `hookfunction`; self-disables otherwise.
- Overly large radius causes obviously impossible hits → server may reject; keep slider range sane
  (×1–×8) and document.
