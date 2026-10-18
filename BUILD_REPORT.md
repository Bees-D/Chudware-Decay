# Build Report — Chudware (Decay)

**Game:** Decay Server (placeId 97393041934796)
**Dump:** Xeno/Dumps/Decay_Server_97393041934796
**UI Library:** Rayfield (Amethyst / purple-blue theme)
**Date:** 2026-10-18

## Summary

- **27 features** researched against dump
- **27 features built** (some with UNSUPPORTED sub-parts noted below)
- **1 security tab** with 27 vulnerability surface tests
- **33 files** total (5 core + 2 ui + 25 features + init.luau)
- All remotes verified against dump and network.md

## File Structure

```
Chudware/
├── init.luau              ← ENTRY POINT (execute this)
├── core/
│   ├── services.luau      cached game services
│   ├── util.luau          math/highlight/Drawing helpers
│   ├── config.luau        persisted settings (fs-guarded)
│   ├── remotes.luau       resolved remote handles
│   └── runtime.luau       RenderStepped/Heartbeat manager
├── ui/
│   ├── window.luau        (unused — init.luau creates window directly)
│   └── notify.luau        notification wrapper
├── features/
│   ├── visuals/           11 features
│   ├── combat/            5 features
│   ├── movement/          5 features
│   ├── misc/              4 features
│   └── security/          1 feature (vuln test)
├── research/              28 research notes (ground truth)
├── FEATURE_MATRIX.md      coverage matrix
└── BUILD_REPORT.md        this file
```

## How to Run

1. Copy the `Chudware/` folder to your executor's workspace directory
2. Execute: `loadstring(readfile("Chudware/init.luau"))()`
3. The Rayfield window opens with 5 tabs: Visuals, Combat, Movement, Misc, Security
4. Toggle features from the UI. Config auto-saves to `Chudware_Decay.json`.

## Tabs

### Visuals
TC ESP, Player/Sleeper ESP, Skeleton ESP, Base/Trap ESP, Loot/Storage ESP, Resource/Ore ESP, Vehicle ESP, Chams, Fullbright, Freecam (P key), Custom Crosshair

### Combat
No Recoil, Aimbot (C key hold, with smoothing + prediction), Silent Aim (namecall hook), No Spread/Sway, Thick Bullets — combat features that require `hookfunction`/`__namecall` self-disable on executors that lack them.

### Movement
Fly & Noclip (**ANTICHEAT RISK** — marked in UI), Always Sprint, High Jump & Spider Climb, Silent Walk (hook-based), No Fall Damage (best-effort velocity cap)

### Misc
Fast Swing (server may rate-limit), Material Farm Bot (basic gather-nearest), Node Crit Assist (snap to spark), Auto Loot (pickup ground items, container support partial)

### Security
Tests 27 vulnerability surfaces from the VulnScan report against live game instances. Each surface shows as resolved (found) or not found. Categories: leak, client-admin, dupe-vector, remotefunction, stat_write, predictability. Re-scan button available.

## UNSUPPORTED Features / Sub-parts

| Item | Reason |
|------|--------|
| TC upkeep display | No `Upkeep` field in dump (grep = 0) |
| Others' hotbar items | Inventory is server-held; not replicated to other clients |
| Auto-turret, Landmine, SAM site | Not present in this game's dump |
| Patrol helicopter, Bradley APC, Scientist NPC, Minicopter, Horse | Not present in dump |
| Buried stashes / Backpacks | No "Stash"/"Backpack" in dump |
| Hemp nodes | Grep = 0; may not exist or named differently |
| Full material bot (navmesh traversal) | Ships basic gather-nearest loop only |
| Auto-loot containers (slot enumeration) | Partial — needs storage UI reference for full auto-move |
| No Fall Damage (server-side) | Best-effort velocity cap; server may still compute damage independently |

## Executor Requirements

| Capability | Features that need it |
|------------|----------------------|
| `hookfunction` | No Recoil (hook), No Spread, Thick Bullets |
| `getrawmetatable` + `setreadonly` | Silent Aim, Silent Walk |
| `Drawing` API | Player ESP, Skeleton ESP, Crosshair |
| `readfile` / `writefile` | Config persistence, module loading |
| `loadstring` + `game:HttpGet` | Rayfield loader |

Features self-disable when their required capability is missing. The mod still loads and runs with whatever the executor supports.

## Anticheat Notes

- `ReplicatedStorage.AntiCheat.RemoteEvents.Auto` exists (autoclick reporter)
- Movement is "heavily monitored server-side" per spec
- Fly/Noclip marked **HIGH RISK** in UI
- WalkSpeed above 16.5 may trigger detection
- ShotHit is client-authored (strongest offensive surface) but server may cross-validate
