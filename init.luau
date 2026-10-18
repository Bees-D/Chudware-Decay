--[[ Chudware — Decay (placeId 97393041934796)
     Remote loader: fetches all modules from GitHub via game:HttpGet().
     A broken feature logs and is skipped — never aborts the whole mod.
]]

local PAT = "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"
local REPO = "https://" .. PAT .. "@raw.githubusercontent.com/Bees-D/Chudware-Decay/master/"

local function load(path)
	local url = REPO .. path
	local ok, content = pcall(function() return game:HttpGet(url) end)
	if not ok then error("Cannot fetch " .. path .. ": " .. tostring(content)) end
	if not content or content == "" then error("Empty response for " .. path) end
	local fn, err = loadstring(content, "@" .. path)
	if not fn then error("Parse error in " .. path .. ": " .. tostring(err)) end
	return fn()
end

-- ---- Rayfield UI (purple/blue Amethyst theme) ----
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Chudware",
	LoadingTitle = "Chudware — Decay",
	LoadingSubtitle = "Decay (97393041934796)",
	Theme = "Amethyst",
	ConfigurationSaving = { Enabled = true, FolderName = "Chudware", FileName = "Decay" },
	KeySystem = false,
})

local Tabs = {
	Visuals  = Window:CreateTab("Visuals",  4483362458),
	Combat   = Window:CreateTab("Combat",   4483362458),
	Movement = Window:CreateTab("Movement", 4483362458),
	Misc     = Window:CreateTab("Misc",     4483362458),
	Security = Window:CreateTab("Security", 4483362458),
}

-- ---- core modules (load order matters: services -> util -> config -> remotes -> runtime) ----
_G._chud_modules = {}
local Services = load("core/services.luau")
local Util     = load("core/util.luau")
local Config   = load("core/config.luau")
local Remotes  = load("core/remotes.luau")
local Runtime  = load("core/runtime.luau")

Config.load()

-- ---- ctx ----
local ctx = {
	services = Services,
	config   = Config,
	remotes  = Remotes,
	util     = Util,
	runtime  = Runtime,
	notify   = function(title, content)
		pcall(function()
			Rayfield:Notify({ Title = title, Content = content, Duration = 3 })
		end)
	end,
}

-- ---- feature registry ----
local FEATURES = {
	{ tab = "Visuals",  file = "features/visuals/tc_esp.luau" },
	{ tab = "Visuals",  file = "features/visuals/player_esp.luau" },
	{ tab = "Visuals",  file = "features/visuals/skeleton_esp.luau" },
	{ tab = "Visuals",  file = "features/visuals/base_trap_esp.luau" },
	{ tab = "Visuals",  file = "features/visuals/loot_storage_esp.luau" },
	{ tab = "Visuals",  file = "features/visuals/resource_esp.luau" },
	{ tab = "Visuals",  file = "features/visuals/vehicle_esp.luau" },
	{ tab = "Visuals",  file = "features/visuals/chams.luau" },
	{ tab = "Visuals",  file = "features/visuals/fullbright.luau" },
	{ tab = "Visuals",  file = "features/visuals/freecam.luau" },
	{ tab = "Visuals",  file = "features/visuals/crosshair.luau" },
	{ tab = "Combat",   file = "features/combat/no_recoil.luau" },
	{ tab = "Combat",   file = "features/combat/aimbot.luau" },
	{ tab = "Combat",   file = "features/combat/silent_aim.luau" },
	{ tab = "Combat",   file = "features/combat/no_spread.luau" },
	{ tab = "Combat",   file = "features/combat/thick_bullets.luau" },
	{ tab = "Movement", file = "features/movement/fly_noclip.luau" },
	{ tab = "Movement", file = "features/movement/omnisprint.luau" },
	{ tab = "Movement", file = "features/movement/highjump.luau" },
	{ tab = "Movement", file = "features/movement/silent_walk.luau" },
	{ tab = "Movement", file = "features/movement/no_fall_damage.luau" },
	{ tab = "Misc",     file = "features/misc/fast_swing.luau" },
	{ tab = "Misc",     file = "features/misc/material_bot.luau" },
	{ tab = "Misc",     file = "features/misc/auto_farm.luau" },
	{ tab = "Misc",     file = "features/misc/auto_loot.luau" },
	{ tab = "Security", file = "features/security/vuln_test.luau" },
}

local loaded = 0
local failed = 0
local failedNames = {}

for _, entry in ipairs(FEATURES) do
	local ok, err = pcall(function()
		local mod = load(entry.file)
		mod.init(Tabs[entry.tab], ctx)
	end)
	if ok then
		loaded += 1
	else
		failed += 1
		table.insert(failedNames, entry.file)
		warn("[Chudware] FAILED " .. entry.file .. ": " .. tostring(err))
	end
end

-- ---- start runtime loops ----
Runtime.start()

-- ---- notify ----
local msg = "Loaded " .. loaded .. "/" .. #FEATURES .. " features"
if failed > 0 then msg = msg .. " (" .. failed .. " failed)" end
ctx.notify("Chudware", msg)

if failed > 0 then
	for _, name in ipairs(failedNames) do
		warn("[Chudware] Failed: " .. name)
	end
end

return { ctx = ctx, Rayfield = Rayfield, Window = Window }
