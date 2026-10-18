# Feature Matrix — Chudware (Decay / 97393041934796)

| # | Feature | File | Trust | Status | Dump Evidence |
|---|---------|------|-------|--------|---------------|
| 01 | TC (Base Claim) ESP | features/visuals/tc_esp.luau | local | BUILT | Unified.luau:515,636; ObjectHEALTH_Team.luau:95; AuthorizedPlayers ×45. Upkeep UNSUPPORTED (no field). |
| 02 | Player & Sleeper ESP | features/visuals/player_esp.luau | local | BUILT | ObjectHEALTH_Team.luau:48,121-127; classes.luau rig. Others' hotbar UNSUPPORTED. |
| 03 | Skeleton ESP | features/visuals/skeleton_esp.luau | local | BUILT | classes.luau rig (R15/R6). |
| 04 | Base & Trap ESP | features/visuals/base_trap_esp.luau | local | BUILT | ObjectHEALTH_Team.luau:95; network.md:258-292. Auto-turret/landmine/SAM UNSUPPORTED. |
| 05 | Loot & Storage ESP | features/visuals/loot_storage_esp.luau | local | BUILT | Lootables.luau; Unified.luau:565,681-683; ObjectHEALTH_Team.luau:72-78. Buried stash UNSUPPORTED. |
| 06 | Resource & Ore ESP | features/visuals/resource_esp.luau | local | BUILT | SparkManager.luau:7,30; ItemData.luau:21-57. Node containers are runtime-only (heuristic match). Hemp UNSUPPORTED. |
| 07 | Vehicle ESP | features/visuals/vehicle_esp.luau | local | BUILT (boats only) | Boat ×31, Vehicles ×32. Helicopter/Bradley/scientist/minicopter/horse UNSUPPORTED. |
| 08 | No Recoil | features/combat/no_recoil.luau | client-auth | BUILT | GunShootModule.luau:603-615; RecoilConfig.GetRecoil. |
| 09 | Aimbot | features/combat/aimbot.luau | client-auth | BUILT | GunShootModule.luau:569-573,641-649; camera ray. |
| 10 | Smoothing | (integrated into aimbot) | local | BUILT | Camera CFrame lerp. |
| 11 | Target Prediction | (integrated into aimbot) | local | BUILT | Ballistics.GetConfig/GetVelocities; HRP.AssemblyLinearVelocity. Approximate. |
| 12 | Silent Aim | features/combat/silent_aim.luau | client-auth | BUILT | GunShootModule.luau:391-400,545; ShotHit:FireServer. Requires __namecall hook. |
| 13 | No Spread & No Sway | features/combat/no_spread.luau | local | BUILT | Ballistics.GetVelocities; no explicit Spread/Sway fields. Requires hookfunction. |
| 14 | Thick Bullets | features/combat/thick_bullets.luau | client-auth | BUILT | GunShootModule.luau:321-330,637,671-672; Ballistics.GetConfig HitRadius. Requires hookfunction. |
| 15 | Fly & Noclip | features/movement/fly_noclip.luau | server-auth | BUILT [AC RISK] | ObjectHEALTH_Team.luau:48 rig; Auto.luau:21 anticheat. |
| 16 | Always Sprint | features/movement/omnisprint.luau | client-auth | BUILT | Sprint.luau:161-184,206,229; Humanoid.WalkSpeed client-set. |
| 17 | High Jump & Spider | features/movement/highjump.luau | client-auth | BUILT | JumpPower ×65, JumpHeight ×84; HRP CFrame client-owned. |
| 18 | Silent Walk | features/movement/silent_walk.luau | local | BUILT | network.md:941-950; MakeSoundClient. Requires __namecall hook. |
| 19 | No Fall Damage | features/movement/no_fall_damage.luau | server-auth | BUILT (best-effort) | WoundedClient; no client FallDamage remote. Velocity-cap only. |
| 20 | Fast Swing | features/misc/fast_swing.luau | server-auth | BUILT | FULL_DUMP.luau:7123,7174; ToolSystem.RemoteEvents.Swing; Replication.Events.Attack. Server may rate-limit. |
| 21 | Material Farm Bot | features/misc/material_bot.luau | mixed | BUILT (basic) | SparkManager.luau; ToolSystem.Swing; Humanoid:MoveTo. Basic gather-nearest loop, not full navmesh. |
| 22 | Fullbright | features/visuals/fullbright.luau | local | BUILT | TimeChanger.luau:15-81,156-227; Lighting properties. |
| 23 | Chams | features/visuals/chams.luau | local | BUILT | Unified.luau:12,60; native Highlight compatible. |
| 24 | Freecam | features/visuals/freecam.luau | local | BUILT | GunShootModule.luau:48; Camera.CameraType Scriptable. |
| 25 | Node Crit Assist | features/misc/auto_farm.luau | local | BUILT | SparkManager.luau:30-57; SpawnSpark/RemoveSpark events. |
| 26 | Auto Loot | features/misc/auto_loot.luau | client-auth | BUILT | Unified.luau:559-569; LootSystem.PickUpRequest; Inventory.StorageRemoteEvents. |
| 27 | Custom Crosshair | features/visuals/crosshair.luau | local | BUILT | Camera.ViewportSize center (GunShootModule.luau:49-50). |

## Security Tab
| Feature | File | Description |
|---------|------|-------------|
| Vuln Test | features/security/vuln_test.luau | Tests 27 vulnerability surfaces from VulnScan report. Resolves each remote/instance, shows green (reachable) / red (failed). |

## UNSUPPORTED Sub-parts
- TC upkeep display (no Upkeep field in dump)
- Others' hotbar items (server-held inventory)
- Auto-turret, landmine, SAM site (not in game)
- Patrol helicopter, Bradley APC, scientist NPC, minicopter, horse (not in game)
- Buried stashes / backpacks (no Stash/Backpack in dump)
- Hemp nodes (grep = 0)
