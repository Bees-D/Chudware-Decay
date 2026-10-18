# 25 — Auto-Farm / Node Hitbox Assist

**Spec:** "Automates hitting resource nodes directly on the critical hit spot (the sparkling marker
or red crosshair) for maximum yield ... whenever a node is hit manually."

**Dump evidence**
- The crit "sparkle" is the Spark marker: `Resources.RemoteEvents.SpawnSpark` (S2C) spawns
  `Resources.Ores.Spark` cloned onto the node at a CFrame; `SetHasSpark`/`RemoveSpark` manage it
  (SparkManager.luau:30-57; network.md:884-910). `ServerSideHitbox` template also under `Resources.Ores`
  (FULL_DUMP.luau:61732).
- So hitting the Spark's position = the crit spot for max yield.

**Trust:** local (aim assist onto an existing marker; damage/harvest still via normal Swing).

**Implementation**
- Track active sparks: listen to `SpawnSpark.OnClientEvent` (CFrame, node) and record the spark
  world position; clear on `RemoveSpark`/`SetHasSpark(false)`. Or find the live `Spark` model under
  the node being harvested.
- Node Hitbox Assist: while harvesting and a spark exists, snap/lerp camera (or the swing raycast
  target) onto the spark position so manual hits land on the crit spot.

**UI:** toggle "Node Crit Assist".

**Risks**
- Only assists while a spark is present (the game's own crit window); no spark = no effect. This is
  aim-assist, not a yield multiplier (yield is server-side). Documented.
