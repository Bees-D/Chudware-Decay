# 01 — TC (Base Claim) ESP

**Spec:** "TC ESP ... Locates a base's Tool Cupboard through walls, often displaying
structural health, authorized players, and remaining upkeep."

**Dump evidence**
- The game's Tool-Cupboard equivalent is the **Base Claim** deployable.
  - `Unified.luau:515` — `v2:FindFirstChild("BaseClaim") and v2.BaseClaim.Value and not v2.BaseClaim.Value.AuthorizedPlayers:FindFirstChild(LocalPlayer.UserId)`
  - `Unified.luau:636,661,704` — `AuthorizedPlayers = v35:FindFirstChild("AuthorizedPlayers")`
  - Build remote: `Build:FireServer(..., "Base Claim", CFrame, n1)` (network.md:261)
  - `FULL_DUMP.luau`: AuthorizedPlayers ×45, BaseClaim ×31.
- Lives in `workspace.PlayerBuiltStructures.Deployables` (ObjectHEALTH_Team.luau:95).
- `.BaseClaim.Value.AuthorizedPlayers` = Folder/Instance whose **children are named by UserId**
  (`:FindFirstChild(LocalPlayer.UserId)`), so authorized players = children names.
- Health: deployable `.Health` (Value), max = `ItemData.Items["Base Claim"].Health` (ObjectHEALTH_Team.luau:97-99).

**Trust:** local (render only).

**Implementation**
- Scan `workspace.PlayerBuiltStructures.Deployables:GetChildren()` for models containing a
  `BaseClaim` ObjectValue (or named "Base Claim"). BillboardGui/Drawing label through walls.
- Label: `"TC  <health>/<maxhp>  auth:<n>"` and expand to list `AuthorizedPlayers` child names
  (resolve UserId → name via `Players:GetPlayerByUserId` when online).

**UI:** toggle "TC ESP", color picker, max-distance slider.

**Risks / UNSUPPORTED**
- **Upkeep: UNSUPPORTED** — no `Upkeep` field anywhere in the dump (grep Upkeep = 0). Do not
  fabricate an upkeep number; omit that column.
- AuthorizedPlayers children keyed by UserId string; offline players show the raw id.
