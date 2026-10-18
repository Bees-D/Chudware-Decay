# 19 — No Fall Damage

**Spec:** "Disables or bypasses velocity calculations upon landing to negate damage from high falls."

**Dump evidence**
- Wounded/health system: `StarterCharacterScripts.WoundedClient` + `ReplicatedStorage.Wounded`
  remotes (Reset/Revive, network.md:1136-1153). Health lives on `Humanoid.Health`.
- Fall damage source is not exposed in a client remote (server-side computation likely) — no client
  `FallDamage` symbol found.

**Trust:** server-auth (uncertain) — client can only mitigate.

**Implementation (best-effort)**
- Just-before-landing velocity cap: each RenderStepped, if `HRP.AssemblyLinearVelocity.Y` is below a
  large-negative threshold and a short downward ray is about to hit ground, clamp the downward
  velocity (set `AssemblyLinearVelocity` Y toward ~0). This removes the high landing speed that fall
  damage is computed from.
- Alternative: keep `Humanoid.StateType` out of Freefall landing spike via `Humanoid:ChangeState`.

**UI:** toggle "No Fall Damage".

**Risks / partial**
- If the server computes fall damage from its own replicated velocity, client velocity-capping may
  not fully prevent it. Documented as best-effort in BUILD_REPORT. No fabricated remote is used.
