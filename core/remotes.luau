--[[ core/remotes.luau — resolved remote handles + required modules, straight from the dump.
     Every path here is traceable to network.md / the decompiled sources. Nothing is invented.
     Resolution is lazy + pcall-guarded so a missing path degrades the owning feature only. ]]

local Services = _G._chud_modules and _G._chud_modules.services or require(script.Parent.services)
local RS = Services.ReplicatedStorage

local Remotes = {}

-- resolve a dotted path under ReplicatedStorage, waiting briefly, returning nil on failure
local function resolve(path)
	local node = RS
	for seg in string.gmatch(path, "[^%.]+") do
		if not node then return nil end
		local ok, child = pcall(function() return node:FindFirstChild(seg) or node:WaitForChild(seg, 5) end)
		node = ok and child or nil
	end
	return node
end

-- cache wrapper
local cache = {}
local function get(path)
	if cache[path] == nil then cache[path] = resolve(path) or false end
	local v = cache[path]
	if v == false then return nil end
	return v
end

-- ---- remote handles (path, direction) — see research/00_feature_matrix.md ----
function Remotes.Shot()        return get("GunSystem.RemoteEvents.Shot") end        -- C2S {ShotId,CameraOrigin,CameraDirection,MuzzleOrigin,Slot,ClientTime,FirstShot}
function Remotes.ShotHit()     return get("GunSystem.RemoteEvents.ShotHit") end     -- C2S { {ShotId,Pellet,Part,Position,Time}, ... }
function Remotes.Reload()      return get("GunSystem.RemoteEvents.Reload") end      -- C2S
function Remotes.PickUpRequest()  return get("LootSystem.RemoteEvents.PickUpRequest") end  -- C2S (handle)
function Remotes.OpenCrate()      return get("LootSystem.RemoteEvents.OpenCrate") end      -- Bindable (local)
function Remotes.QuickMoveFromStorage() return get("Inventory.StorageRemoteEvents.QuickMoveFromStorage") end -- C2S (obj, slot)
function Remotes.StorageMoveTo()  return get("Inventory.StorageRemoteEvents.MoveTo") end   -- C2S
function Remotes.Swing()       return get("ToolSystem.RemoteEvents.Swing") end      -- melee hit
function Remotes.Use()         return get("ToolSystem.RemoteEvents.Use") end        -- C2S (slot)
function Remotes.Attack()      return get("Replication.Events.Attack") end          -- C2S (ItemName, ItemType)
function Remotes.MakeSoundClient() return get("SoundService.RemoteEvents.MakeSoundClient") end -- C2S (sound,pos)
function Remotes.Crouch()      return get("Players.Crouch") end                     -- C2S (bool)
function Remotes.SpawnSpark()  local r = get("Resources.RemoteEvents") ; return r and r:FindFirstChild("SpawnSpark") end
function Remotes.RemoveSpark() local r = get("Resources.RemoteEvents") ; return r and r:FindFirstChild("RemoveSpark") end
function Remotes.SetHasSpark() local r = get("Resources.RemoteEvents") ; return r and r:FindFirstChild("SetHasSpark") end
function Remotes.SupplyDropNotification() return get("SupplyDrops.SupplyDropNotification") end -- S2C

-- ---- required game modules (ground truth tables) ----
local moduleCache = {}
local function requireModule(path)
	if moduleCache[path] ~= nil then
		local v = moduleCache[path]; if v == false then return nil end; return v
	end
	local inst = get(path)
	if not inst then moduleCache[path] = false; return nil end
	local ok, mod = pcall(require, inst)
	moduleCache[path] = (ok and mod) or false
	return (ok and mod) or nil
end

function Remotes.ItemData()    return requireModule("ItemData") end        -- .Items[name] = {Type,Health,FireRate,...}
function Remotes.Structures()  return requireModule("Structures") end      -- .StructureHealth(name, upgrade)
function Remotes.RecoilConfig() return requireModule("RecoilConfig") end   -- .GetRecoil(bulletNum, itemName)
function Remotes.Ballistics()  local gs = get("GunSystem"); if not gs then return nil end
	local b = gs:FindFirstChild("Ballistics"); if not b then return nil end
	local ok, m = pcall(require, b); return ok and m or nil end

-- generic safe fire
function Remotes.fireServer(remote, ...)
	if not remote then return false end
	local ok = pcall(function(...) remote:FireServer(...) end, ...)
	return ok
end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.remotes = Remotes
return Remotes
