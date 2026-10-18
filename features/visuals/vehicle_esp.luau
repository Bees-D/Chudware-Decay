local Feature = {}
Feature.name = "Vehicle ESP"
Feature.group = "Visuals"

local enabled = false
local maxDist = 1000
local espColor = Color3.fromRGB(0, 200, 255)
local highlights = {}
local scanCache = {}
local scanTick = 0
local SCAN_INTERVAL = 3
local UPDATE_INTERVAL = 0.5
local lastUpdate = 0

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Vehicle ESP")
	tab:CreateToggle({ Name = "Vehicle ESP", CurrentValue = false, Flag = "vehicle_esp_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Max Distance", Range = {100, 3000}, Increment = 100, CurrentValue = 1000, Flag = "vehicle_esp_dist", Callback = function(v) maxDist = v end })
	tab:CreateColorPicker({ Name = "Vehicle Color", Color = espColor, Flag = "vehicle_esp_color", Callback = function(v) espColor = v end })

	local function isVehicle(inst)
		if not inst:IsA("Model") then return false end
		local lower = string.lower(inst.Name)
		return string.find(lower, "boat") or string.find(lower, "vehicle") or string.find(lower, "car") or string.find(lower, "raft")
	end

	local function scan()
		local now = tick()
		if now - scanTick < SCAN_INTERVAL then return scanCache end
		scanTick = now
		scanCache = {}
		local count = 0
		for _, inst in ipairs(workspace:GetDescendants()) do
			if count > 2000 then break end
			count += 1
			if isVehicle(inst) then
				table.insert(scanCache, inst)
			end
		end
		return scanCache
	end

	R.onHeartbeat("vehicle_esp", function()
		if not enabled then return end

		local now = tick()
		if now - lastUpdate < UPDATE_INTERVAL then return end
		lastUpdate = now

		local hrp = S.HRP()
		if not hrp then return end

		local items = scan()
		local seen = {}

		for _, inst in ipairs(items) do
			if U.alive(inst) then
				local pos = U.positionOf(inst)
				if pos and (pos - hrp.Position).Magnitude <= maxDist then
					seen[inst] = true
					U.setHighlight(inst, { FillColor = espColor, FillTransparency = 0.6, OutlineColor = espColor, OutlineTransparency = 0 })
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
