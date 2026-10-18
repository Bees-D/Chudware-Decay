# 05 — Loot & Storage ESP

**Spec:** "Outlines buried stashes, small/large wooden boxes, military/elite crates, supply
drops, and dropped backpacks."

**Dump evidence**
- Lootable crate model names (Lootables.luau): `Crate`, `Military Crate`, `Food Crate`,
  `Supply Drop`, `Locked Crate`, `Scientist`.
- Supply drop event: `ReplicatedStorage.SupplyDrops.SupplyDropNotification` S2C (network.md:972).
- Grabbable ground items: `inst:GetAttribute("Grabbable")`, with `.Amount` + `.ItemName`
  (Unified.luau:565,681-683).
- Storage boxes: `Deployables.RemoteEvents.OpenCrate/OpenBodyBag` bindables (network.md:342,334);
  BodyBag ×5 in dump.
- Barrels (loot): BasePart "Barrel", Health max 50 (ObjectHEALTH_Team.luau:72-78).

**Trust:** local.

**Implementation**
- Scan workspace (throttled descendants pass, cached) for: models whose `.Name` ∈ Lootables.Crates
  set; instances with `GetAttribute("Grabbable")`; parts named "Barrel". Highlight + label with
  `ItemName`/`Amount` when present. Group toggles: Crates / Barrels / Dropped Items / Supply Drops.
- Supply drop: also subscribe to `SupplyDropNotification.OnClientEvent` to flag active drops.

**UI:** master + per-group toggles, color, max-distance.

**Risks / UNSUPPORTED**
- **Buried stashes / backpacks: UNSUPPORTED as named** — no "Stash"/"Backpack" in dump (grep=0).
  Dropped bags map to BodyBag + Grabbable items; represent those instead, do not invent a stash type.
- Full workspace descendant scan is heavy → throttle (scan N per frame, cache results ~0.5 s).
