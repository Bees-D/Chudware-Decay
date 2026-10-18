# 21 — Material Farming Bot

**Spec:** "Autonomous ... bots that fully take over character movement to traverse the map,
automatically identify, target, and gather resource nodes ... and return to base or store materials."

**Dump evidence**
- Node identification reuses [[06_resource_ore_esp]] (resource model scan + Spark markers).
- Gather = melee swing on the node: `ToolSystem.RemoteEvents.Swing` ([[20_fast_swing]]).
- Movement = client-owned HRP (same as [[15_fly_noclip]]); pathing via `Humanoid:MoveTo` (standard).
- Storage: `Inventory.StorageRemoteEvents.QuickMoveToStorage:FireServer(obj, slot)` /
  `AddTo:FireServer(...)` (network.md:650-657, 604-615) for depositing into a box.

**Trust:** local movement + client-auth gather/store remotes.

**Implementation (scoped automation)**
- State machine: FIND nearest resource node (scanner) → `Humanoid:MoveTo(nodePos)` → when in range,
  equip harvest tool + repeat Swing until node gone → repeat. Optional RETURN: MoveTo a saved base
  position and QuickMoveToStorage into a targeted box.
- Start/stop toggle; safety stop if health drops or enemy near.

**UI:** toggle "Auto Farm Bot", node-type filter, "set home position" button, stop-on-threat toggle.

**Risks / partial**
- Full autonomous map traversal with obstacle avoidance is large; this ships a **basic
  gather-nearest + optional return-to-home** loop, not a full navmesh bot. Documented as partial.
- Server gather rate-limits ([[20_fast_swing]]) apply. Movement anticheat ([[15_fly_noclip]]) applies
  if speeds are boosted — keep MoveTo at normal WalkSpeed.
