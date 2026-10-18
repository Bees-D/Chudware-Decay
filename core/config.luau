--[[ core/config.luau — persisted settings with guarded writefile/readfile.
     Rayfield already persists Flag-bound controls; this is a secondary store for non-Flag
     values (saved positions, filters). Missing filesystem degrades to in-memory only. ]]

local Util = _G._chud_modules and _G._chud_modules.util or require(script.Parent.util)

local Config = {}
local FILE = "Chudware_Decay.json"
local state = {}

local HttpGet = game.HttpGetAsync and game or nil -- unused; kept for parity

local function serialize(t)
	-- tiny JSON via HttpService (always available)
	local ok, s = pcall(function()
		return game:GetService("HttpService"):JSONEncode(t)
	end)
	return ok and s or nil
end

local function deserialize(s)
	local ok, t = pcall(function()
		return game:GetService("HttpService"):JSONDecode(s)
	end)
	return ok and t or nil
end

function Config.load()
	if not Util.caps.fs then return end
	local ok, exists = pcall(isfile, FILE)
	if ok and exists then
		local okr, content = pcall(readfile, FILE)
		if okr and content then
			local t = deserialize(content)
			if type(t) == "table" then state = t end
		end
	end
end

function Config.save()
	if not Util.caps.fs then return end
	local s = serialize(state)
	if s then pcall(writefile, FILE, s) end
end

function Config.get(key, default)
	local v = state[key]
	if v == nil then return default end
	return v
end

function Config.set(key, value)
	state[key] = value
	Config.save()
end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.config = Config
return Config
