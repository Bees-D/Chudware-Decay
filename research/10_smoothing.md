# 10 — Smoothing

**Spec:** "Slows down aim snap speeds to simulate natural human mouse movement to evade detection."

**Dump evidence**
- Shares the camera-snap path of [[09_aimbot]] (`workspace.CurrentCamera.CFrame`, GunShootModule
  reads camera ray each shot, GunShootModule.luau:569-573). No server symbol needed — this modifies
  how fast the local camera moves.

**Trust:** local.

**Implementation**
- Replace the hard `lookAt` snap with a per-frame interpolation toward the target CFrame:
  `cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(camPos, targetPos), alpha)` where
  `alpha = clamp(dt * smoothnessFactor, 0, 1)`. Higher slider = faster snap.
- Used by the aimbot module as its camera-apply step; exposed as its own control.

**UI:** smoothing slider (1 = slow/human … 20 = near-instant) shared with aimbot.

**Risks**
- Too-low smoothing + fast target = never catches up; clamp minimum.
