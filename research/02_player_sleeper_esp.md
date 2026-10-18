# 02 — Player & Sleeper ESP

**Spec:** "Displays nearby players and sleepers with ... 3D bounding boxes, health bars,
active held weapon, hotbar items, team status, and distance."

**Dump evidence**
- Players standard: `Players:FindFirstChild(name)`, character `workspace[name]` with
  `Humanoid` + `HumanoidRootPart` (ObjectHEALTH_Team.luau:48,121-122; classes.luau rig).
- Health: `Humanoid.Health` / `Humanoid.MaxHealth`.
- Team: `player.CustomTeam.Value` (0 = none), `.CustomTeam.Leader.Value` (ObjectHEALTH_Team.luau:124-127).
- Sleepers: `FULL_DUMP.luau` Sleeper ×5 (disconnected player bodies persist as characters).
- Held weapon: equipped tool model under the character / `Character:FindFirstChildOfClass("Tool")`
  or the character's weapon model name; ItemData.Items for display name (ItemData.luau).

**Trust:** local.

**Implementation**
- Iterate `Players:GetPlayers()` (skip LocalPlayer) + scan for sleeper bodies (character models
  in workspace with Humanoid whose player is absent). For each: 2D box (Drawing API via
  `WorldToViewportPoint` over HRP + size), health bar, name, distance (`(hrp-localHRP).Magnitude`),
  team color (same CustomTeam.Value as local = friendly green, else red).
- Held weapon: read equipped Tool/weapon model name.

**UI:** toggles box/healthbar/name/distance/weapon/team-color; friendly filter; max-distance.

**Risks / UNSUPPORTED**
- **Others' hotbar items: UNSUPPORTED** — inventory/hotbar is server-held; an injected client
  cannot see another player's hotbar contents (no replicated remote exposes it). Held/equipped
  weapon IS visible (it is a rendered model). Show weapon only; omit full hotbar.
- Reading parts of a dying/destroyed character can error → wrap in pcall, skip nil HRP.
