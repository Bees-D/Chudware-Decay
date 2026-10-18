# 20 — No Swing Cooldown / Fast Swing

**Spec:** "Removes or minimizes the artificial delay between melee swings, tool hits, or weapon
attack animations ... rapid harvesting, melee combat, or soft-side eco-raiding."

**Dump evidence**
- Melee/tool hit remote: `ReplicatedStorage.ToolSystem.RemoteEvents.Swing` fired via a tool module
  `v59.Hit(Swing, toolName)` and `v59.SwingFunction(Swing, v69, Name, mouse.Target)`
  (FULL_DUMP.luau:7123,7174; network.md:1086).
- Also `Replication.Events.Attack:FireServer(ItemName, ItemType)` per attack
  (FULL_DUMP.luau:7161). Cooldown/animation is gated by a client swing token in HotbarScript
  ("tool swing token mismatch", FULL_DUMP.luau:7166).

**Trust:** server-auth risk (server likely rate-limits harvest/damage).

**Implementation**
- Fast swing: on a repeating loop while the swing key is held and a melee tool is equipped, fire
  `ToolSystem.RemoteEvents.Swing` (and `Replication.Events.Attack:FireServer(itemName, itemType)`)
  at an interval slider, reading the equipped tool's `ItemName`/`ItemType` the same way the game does.
  This bypasses the client animation-token gate by driving the remote directly.

**UI:** toggle "Fast Swing" + swings-per-second slider, keybind.

**Risks**
- Server may validate swing cadence / only credit hits at the real rate → extra fires ignored or
  flagged. Keep default rate modest; documented as server-authority-dependent.
