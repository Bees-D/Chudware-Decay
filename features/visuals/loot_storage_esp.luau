local Feature = {}
Feature.name = "Loot & Storage ESP"
Feature.group = "Visuals"

local enabled = false
local maxDist = 500
local showCrates = true
local showBarrels = true
local showDropped = true
local showSupply = true

local CRATE_NAMES = { ["Crate"] = true, ["Military Crate"] = true, ["Food Crate"] = true, ["Supply Drop"] = true, ["Locked Crate"] = true, ["Scientist"] = true }
local CRATE_COLOR = Color3.fromRGB(255, 220, 50)
local BARREL_COLOR = Color3.fromRGB(200, 130, 50)
local DROP_COLOR = Color3.fromRGB(100, 255, 100)

local highlights = {}
local scanCache = {}
local scanTick = 0
local SCAN_INTERVAL = 3
local UPDATE_INTERVAL = 0.5
local lastUpdate = 0
local MAX_SCAN_ITEMS = 2000

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Loot & Storage ESP")
	tab:CreateToggle({ Name = "Loot ESP", CurrentValue = false, Flag = "loot_esp_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateToggle({ Name = "Crates", CurrentValue = true, Flag = "loot_esp_crates", Callback = function(v) showCrates = v end })
	tab:CreateToggle({ Name = "Barrels", CurrentValue = true, Flag = "loot_esp_barrels", Callback = function(v) showBarrels = v end })
	tab:CreateToggle({ Name = "Dropped Items", CurrentValue = true, Flag = "loot_esp_drops", Callback = function(v) showDropped = v end })
	tab:CreateToggle({ Name = "Supply Drops", CurrentValue = true, Flag = "loot_esp_supply", Callback = function(v) showSupply = v end })
	tab:CreateSlider({ Name = "Max Distance", Range = {50, 2000}, Increment = 50, CurrentValue = 500, Flag = "loot_esp_dist", Callback = function(v) maxDist = v end })

	local function scan()
		local now = tick()
		if now - scanTick < SCAN_INTERVAL then return scanCache end
		scanTick = now
		scanCache = {}

		local count = 0
		for _, inst in ipairs(workspace:GetDescendants()) do
			if count > MAX_SCAN_ITEMS then break end
			count += 1
			if inst:IsA("Model") and CRATE_NAMES[inst.Name] then
				table.insert(scanCache, { inst = inst, kind = "crate" })
			elseif inst:IsA("BasePart") and inst.Name == "Barrel" then
				table.insert(scanCache, { inst = inst, kind = "barrel" })
			elseif U.try(function() return inst:GetAttribute("Grabbable") end) then
				table.insert(scanCache, { inst = inst, kind = "drop" })
			end
		end
		return scanCache
	end

	R.onHeartbeat("loot_esp", function()
		if not enabled then return end

		local now = tick()
		if now - lastUpdate < UPDATE_INTERVAL then return end
		lastUpdate = now

		local hrp = S.HRP()
		if not hrp then return end

		local items = scan()
		local seen = {}

		for _, entry in ipairs(items) do
			local inst = entry.inst
			local kind = entry.kind
			if U.alive(inst) then
				local show = (kind == "crate" and showCrates) or (kind == "barrel" and showBarrels) or (kind == "drop" and showDropped)
				if show then
					local pos = U.positionOf(inst)
					if pos and (pos - hrp.Position).Magnitude <= maxDist then
						seen[inst] = true
						local color = (kind == "crate" and CRATE_COLOR) or (kind == "barrel" and BARREL_COLOR) or DROP_COLOR
						U.setHighlight(inst, { FillColor = color, FillTransparency = 0.7, OutlineColor = color, OutlineTransparency = 0 })
					end
				end
			end
		end

		for inst in pairs(highlights) do
			if not seen[inst] then U.clearHighlight(inst); highlights[inst] = nil end
		end
		for inst in pairs(seen) do highlights[inst] = true end
	end)
end

function Feature.toggle(state)
	enabled = state
	if not state then
		for inst in pairs(highlights) do U.clearHighlight(inst) end
		highlights = {}
		scanCache = {}
	end
end

return Feature
