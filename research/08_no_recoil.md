# 08 — No Recoil

**Spec:** "Dampens or entirely removes weapon recoil patterns."

**Dump evidence**
- Recoil is applied client-side: `RecoilSpring:shove(v47)` where
  `v47 = RecoilConfig.GetRecoil(BulletNumber, Value)` (GunShootModule.luau:603-615).
- `RecoilConfig = require(ReplicatedStorage.RecoilConfig)` (GunShootModule.luau:16).
- Recoil moves the local camera/viewmodel spring only — not sent to server.

**Trust:** client-auth (purely local visual spring).

**Implementation**
- Preferred: `hookfunction(RecoilConfig.GetRecoil, function(...) return Vector3.zero / 0 end)` so
  shove receives zero. Guard with capability check (`hookfunction` exists). GetRecoil return type is
  the shove arg (treat as Vector3; the module multiplies/`/5` it so a zero value nullifies).
- Fallback (no hookfunction): per-RenderStepped, counter-rotate `workspace.CurrentCamera.CFrame`
  back toward the pre-shot look direction (recoil-compensation). Toggle strength slider.

**UI:** toggle "No Recoil" + strength slider (0–100 %, for the compensation fallback).

**Risks**
- `hookfunction` is executor-specific → feature self-disables if absent (capability guard in core).
- Fallback fights the game's own camera spring; strength slider lets the user tune.
