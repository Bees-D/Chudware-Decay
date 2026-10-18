# 04 — Base & Trap ESP

**Spec:** "Highlights key base components including code locks, doors, auto-turrets, shotgun
traps, landmines, and SAM sites."

**Dump evidence**
- Deployables live in `workspace.PlayerBuiltStructures.Deployables` (ObjectHEALTH_Team.luau:95).
- Confirmed deployable names from Build call sites (network.md:258-292):
  Code Lock, Key Lock (PlaceLock, network.md:411-412), Wooden/Metal/Armored Door(+Double),
  **Shotgun Trap** (network.md:291), **Flame Turret** (network.md:292), High External walls/gates,
  Furnace, Workbench, etc.
- Each deployable model: `.Health`, `.PrimaryPart`, `.Name`; locks have `CanOpenLock` remote.

**Trust:** local.

**Implementation**
- Scan `Deployables:GetChildren()`, classify by `.Name` into groups:
  locks (`Code Lock`,`Key Lock`), doors (name contains "Door"), traps (`Shotgun Trap`),
  turrets (`Flame Turret`), walls/gates (name starts "High External"). Highlight + label
  with health. Per-group toggle + color.

**UI:** master "Base/Trap ESP" + per-group toggles (Locks / Doors / Traps / Turrets / Walls).

**Risks / UNSUPPORTED**
- **Auto-turret / landmine / SAM site: UNSUPPORTED** — not present in dump (only Flame Turret &
  Shotgun Trap exist as traps). Expose only the deployables that exist; label trap group with the
  real names. Classification is name-based; unknown new deployables fall into an "Other" bucket.
