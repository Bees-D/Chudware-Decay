# 06 — Resource & Ore ESP

**Spec:** "Outlines sulfur, metal, and stone nodes, as well as hemp plants, food, and wood piles."

**Dump evidence**
- Resource system: `ReplicatedStorage.Resources` with `.Ores` folder (`Spark`, `ServerSideHitbox`
  templates) and RemoteEvents `SpawnSpark/RemoveSpark/SetHasSpark/AnimateSpark` (SparkManager.luau:7,30;
  network.md:884-910).
- ItemData resource types: `Type = "Resource"` for Wood, Stone, `Metal Ore`, Scrap, Cloth, etc.
  (ItemData.luau:21-57). Sulfur present (grep Sulfur ×2), Metal Ore ×1, Stone ×97, Node ×38.
- Nodes are runtime world models (not in static dump); gather emits a Spark crit marker on the node.

**Trust:** local.

**Implementation**
- Scan workspace for resource node models. Nodes are not centrally containerized in the dump, so
  match by model name against a resource keyword set (Stone, Metal, Sulfur, Wood, Tree, Ore, Hemp,
  Node) and/or presence of a `Spark`/`ServerSideHitbox` child. Highlight + label with node type +
  distance. This is heuristic because node containers are runtime-only — see risks.

**UI:** master "Resource ESP" + per-type toggles (Stone / Metal / Sulfur / Wood), color, distance.

**Risks / UNSUPPORTED**
- Node container path is **not in the dump** (world is runtime-spawned). Matching is name-based and
  may miss nodes with non-obvious names; mark unknown resource-looking models as "Resource?".
- **Hemp / food piles: partial** — "Hemp" grep = 0; may not exist or be named differently. Only
  surface types whose names actually appear; do not fabricate node classes.
- Heavy scan → throttle + cache (shared with [[05_loot_storage_esp]] scanner).
