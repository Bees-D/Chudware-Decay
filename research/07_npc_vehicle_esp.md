# 07 — NPC & Vehicle ESP

**Spec:** "Marks patrol helicopters, Bradley APCs, scientists, minicopters, boats, and horses."

**Dump evidence (mostly negative — honesty gate)**
- grep FULL_DUMP.luau: Helicopter 0, Bradley 0, Scientist 0 (as NPC), Minicopter 0, Horse 0.
- Present: **Boat ×31**, **Vehicles ×32** (`Deployables.RemoteEvents.OpenBoat` bindable, network.md:330).
- "Scientist" exists only as a **loot crate name** in Lootables.Crates, not a roaming NPC.

**Trust:** local.

**Implementation**
- Boats/vehicles: scan workspace for vehicle models (name contains "Boat"/vehicle container) →
  highlight + distance label. Reuse the world scanner from [[05_loot_storage_esp]].

**UI:** toggle "Vehicle ESP" (Boats), color, distance.

**Verdict: PARTIAL**
- **UNSUPPORTED:** patrol helicopter, Bradley APC, scientist NPC, minicopter, horse — none exist
  in this game's dump. Do not render markers for them; the BUILD_REPORT lists them as unsupported.
- **SUPPORTED:** boats (and any model under the vehicle container). Vehicle ESP ships boats-only.
