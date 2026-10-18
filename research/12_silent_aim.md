# 12 — Silent Aim (pSilent)

**Spec:** "Redirects projectile trajectories toward the target without altering the user's visible
crosshair on-screen."

**Dump evidence (the money surface)**
- Hit registration is client-authored: the local Heartbeat loop builds
  `{ShotId, Pellet, Part = v27.Instance, Position = v29, Time = v28}` from its OWN raycast result and
  fires `ShotHit:FireServer(t4)` (GunShootModule.luau:391-400, 545).
- `ShotHit = ReplicatedStorage.GunSystem.RemoteEvents.ShotHit` (GunShootModule.luau:19), direction C2S
  (network.md:555-568). The server trusts the client-claimed `Part` and `Position`.

**Trust:** client-auth — strongest offensive surface in the game.

**Implementation**
- Hook the `ShotHit` remote's outgoing `FireServer` (metatable `__namecall` hook, or `hookfunction`
  on `FireServer`, capability-guarded). When the local player fires, rewrite each entry's `Part` to
  the target's chosen hitbox and `Position` to that part's world position, keeping the real `ShotId`
  / `Pellet` / `Time` so the packet stays well-formed.
- Because the real ShotId comes from the genuine `Shot:FireServer` the module already sent, the
  server sees a consistent shot id with a hit on the target — crosshair never moves.
- Target pick = same selector as [[09_aimbot]]; hitbox dropdown.

**UI:** toggle "Silent Aim", hitbox dropdown, FOV slider, team-check.

**Risks**
- If the server cross-validates `ShotHit.Position` against the ray from `Shot.CameraDirection`, pure
  silent aim may be rejected while camera-snap aimbot ([[09_aimbot]]) still works. Expose both; note
  the trade-off in BUILD_REPORT.
- Requires `__namecall`/`hookfunction`; self-disables without them.
