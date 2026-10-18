# Feature Matrix — Chudware (Decay / placeId 97393041934796)

Dump: `Xeno/Dumps/Decay_Server_97393041934796`. Spec: `Roblox Rust/spec.md`.
Game is a Rust-like base-survival PvP game ("Decay"). Standard Roblox character rig
(Humanoid + HumanoidRootPart). Custom gun/tool/build/loot systems with 152 remotes.

Trust legend: **local** = pure client render/physics, no server call. **client-auth** =
server trusts a client-fired remote (likely works). **server-auth** = server validates /
computes; client attempt may be rejected or flagged by the AntiCheat folder.

| #  | Feature | Group | Trust | Status |
|----|---------|-------|-------|--------|
| 01 | TC (Base Claim) ESP | visuals | local | researched (upkeep UNSUPPORTED — no field) |
| 02 | Player & Sleeper ESP | visuals | local | researched (others' hotbar UNSUPPORTED) |
| 03 | Skeleton ESP | visuals | local | researched |
| 04 | Base & Trap ESP | visuals | local | researched |
| 05 | Loot & Storage ESP | visuals | local | researched |
| 06 | Resource & Ore ESP | visuals | local | researched |
| 07 | NPC & Vehicle ESP | visuals | local | researched (NPCs/heli/bradley UNSUPPORTED; boats OK) |
| 08 | No Recoil | combat | client-auth | researched |
| 09 | Aimbot | combat | client-auth | researched |
| 10 | Smoothing | combat | local | researched |
| 11 | Target Prediction | combat | local | researched |
| 12 | Silent Aim | combat | client-auth | researched |
| 13 | No Spread & No Sway | combat | local | researched (no explicit Spread/Sway field) |
| 14 | Thick Bullets / Ext. Hitbox | combat | client-auth | researched |
| 15 | Flyhack / Noclip | movement | server-auth | researched (HIGH anticheat risk) |
| 16 | Omni-Sprint / Always Sprint | movement | client-auth | researched |
| 17 | Spider-Man / High Jump | movement | client-auth | researched |
| 18 | Silent Walk / Run | movement | local | researched (partial) |
| 19 | No Fall Damage | movement | server-auth | researched (partial) |
| 20 | No Swing Cooldown / Fast Swing | misc | server-auth | researched |
| 21 | Material Farming Bot | misc | local+client-auth | researched (partial automation) |
| 22 | Fullbright / Always Day | misc | local | researched |
| 23 | Chams | misc | local | researched |
| 24 | Debug Camera / Freecam | misc | local | researched |
| 25 | Auto-Farm / Node Hitbox Assist | misc | local | researched |
| 26 | Instant Auto-Loot | misc | client-auth | researched |
| 27 | Custom Crosshair Overlay | misc | local | researched |

GATE STATUS: 27/27 researched. 0 fully UNSUPPORTED (several have UNSUPPORTED sub-parts,
noted inline and in each feature's research file).

## Core dump facts reused across features
- Players: `game.Players` + character model `workspace[player.Name]`, `Humanoid`, `HumanoidRootPart`, `Humanoid.Health/MaxHealth`. (classes.luau; ObjectHEALTH_Team.luau:48,121)
- Team: `player.CustomTeam.Value` (number, 0 = none), `player.CustomTeam.Leader.Value`. (ObjectHEALTH_Team.luau:124-127)
- Base structures: `workspace.PlayerBuiltStructures.Structures.<model>` → `.Health` (Value), `.Upgrade` (Value), `.PrimaryPart`. Max HP = `require(ReplicatedStorage.Structures).StructureHealth(name, upgrade)`. (ObjectHEALTH_Team.luau:52-56)
- Deployables: `workspace.PlayerBuiltStructures.Deployables.<model>` → `.Health`, `.PrimaryPart`, `.Name`. Max HP = `ItemData.Items[name].Health`. (ObjectHEALTH_Team.luau:95-99)
- Base Claim (TC): deployable whose model has `.BaseClaim.Value.AuthorizedPlayers` (children named by UserId). (Unified.luau:515,636,661; dump AuthorizedPlayers×45)
- Loot crates: model `.Name` ∈ {Crate, Military Crate, Food Crate, Supply Drop, Locked Crate, Scientist}. (Lootables.luau)
- Grabbable items: `inst:GetAttribute("Grabbable")`, has `.Amount`, `.ItemName`. (Unified.luau:565,681-683)
- Action objects: `inst:GetAttribute("Action")`. (Unified.luau:633,657,700)
- Barrels: BasePart named "Barrel", `.Health` (max 50). (ObjectHEALTH_Team.luau:72-78)
- ItemData: `require(ReplicatedStorage.ItemData).Items[name]` = {ItemId, Type, Image, Health, MaxInteractDistance, FireRate, ...}. `.Type`="Resource" etc. (ItemData.luau:21+)
- Gun shot: client raycasts bullets locally; on character hit fires `ReplicatedStorage.GunSystem.RemoteEvents.ShotHit:FireServer({{ShotId,Pellet,Part,Position,Time}})`. Server trusts client-claimed `Part`+`Position`. Shot declared via `Shot:FireServer({ShotId,CameraOrigin,CameraDirection,MuzzleOrigin,Slot,ClientTime,FirstShot})`. (GunShootModule.luau:545,641)
- Recoil is local: `RecoilSpring:shove(v47)`, `v47 = RecoilConfig.GetRecoil(bulletNum, itemName)`. (GunShootModule.luau:603-615)
- Ballistics: `require(ReplicatedStorage.GunSystem.Ballistics)` — `.GetVelocities`, `.GetConfig` (Gravity, MaxTime, HitRadius), `.Position`, `.Step`. (GunShootModule.luau:17,637,652)
- Movement: `Humanoid.WalkSpeed` set client-side (12 walk / 16.5 sprint / 8 crouch). `player.IsSprinting`, `player.IsCrouching`, `player.Stats.Water` Values. Crouch → `ReplicatedStorage.Players.Crouch:FireServer(bool)`. (Sprint.luau:206-229,258)
- AntiCheat present: `ReplicatedStorage.AntiCheat.RemoteEvents.Auto` (autoclick reporter). Movement "heavily monitored server-side" per spec. (Auto.luau:21)
- Lighting driven every change by TimeChanger from `ReplicatedStorage.Time.Value` + `player.GlobalTime.Value`; fullbright must re-assert each frame. (TimeChanger.luau:193-227)
- Game already uses `Highlight` instances for pickup glow → chams/ESP via Highlight is native-compatible. (Unified.luau:12,60; PickUpClient.luau)
