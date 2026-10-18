# 26 — Instant Auto-Loot

**Spec:** "Instantly moves high-value items into the user's inventory upon opening a container or
body."

**Dump evidence**
- Opening a crate/body uses local bindables `LootSystem.RemoteEvents.OpenCrate:Fire(model)` /
  `OpenBodyBag`/`OpenCrate` (Lootables.luau:15; network.md:342,334,751).
- Moving loot out of an opened storage into the player: `Inventory.StorageRemoteEvents.QuickMoveFromStorage:FireServer(obj, slot)`
  and `MoveTo`/`AddTo`/`Switch` on the same C2S set (network.md:641-671).
- Ground grabbables: `LootSystem.RemoteEvents.PickUpRequest:FireServer(handle)` (Unified.luau:559-569;
  network.md:755-764).

**Trust:** client-auth (these are the game's own C2S loot-move remotes).

**Implementation**
- On opening a container (hook the Open bindable, or detect the storage UI opening), enumerate the
  storage slots the client now sees and fire `QuickMoveFromStorage:FireServer(obj, slot)` for each
  (optionally filtered by ItemData `.Type`/value). For ground loot, auto-fire `PickUpRequest` for
  nearby `Grabbable` items within a radius.

**UI:** toggle "Auto Loot (containers)", toggle "Auto Pickup (ground)", pickup radius slider,
value/type filter.

**Risks**
- Server validates each move; invalid/locked slots are rejected (expected, harmless). Rate the
  per-slot fires to avoid flooding. Only slots the client can already see are moveable.
