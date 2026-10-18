# 15 — Flyhack / Noclip

**Spec:** "Detaches the player model from ground collision, allowing flight or passage through solid
walls (though heavily monitored by modern server-side checks)."

**Dump evidence**
- Standard character: `Humanoid` + `HumanoidRootPart` (ObjectHEALTH_Team.luau:48). CFrame/velocity
  are client-owned for the local character (Roblox default network ownership).
- There IS server-side monitoring: `ReplicatedStorage.AntiCheat.RemoteEvents.Auto` (Auto.luau) plus
  the spec's own warning. An admin `Fly` remote exists but is auth-gated (network.md:13, direction
  unknown — not usable).

**Trust:** server-auth risk (position is client-owned so it *moves*, but the AntiCheat may flag/teleport-back).

**Implementation**
- Fly: on toggle, set `Humanoid.PlatformStand = true`, create a `BodyVelocity`/`LinearVelocity` +
  `BodyGyro`/`AlignOrientation` on HRP, drive velocity from camera look + WASD, speed slider.
  Remove on toggle-off, restore PlatformStand.
- Noclip: each RenderStepped set `CanCollide = false` on all character BaseParts (cache + restore).

**UI:** toggles "Fly" / "Noclip", fly-speed slider, keybinds.

**Risks**
- HIGH anticheat exposure (spec + Auto reporter). Ship with a visible warning in the UI tooltip and
  BUILD_REPORT. Keep speeds moderate by default. Feature works mechanically; acceptance by the
  server is not guaranteed.
