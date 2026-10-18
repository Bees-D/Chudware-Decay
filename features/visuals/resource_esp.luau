local Feature = {}
Feature.name = "Resource & Ore ESP"
Feature.group = "Visuals"

local enabled = false
local maxDist = 500
local showStone = true
local showMetal = true
local showSulfur = true
local showWood = true

local RESOURCE_KEYWORDS = { Stone = true, Metal = true, Sulfur = true, Wood = true, Tree = true, Ore = true, Node = true }
local COLORS = {
	Stone = Color3.fromRGB(180, 180, 180),
	Metal = Color3.fromRGB(200, 150, 80),
	Sulfur = Color3.fromRGB(255, 255, 0),
	Wood = Color3.fromRGB(139, 90, 43),
}
local highlights = {}
local scanCache = {}
local scanTick = 0

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Resource & Ore ESP")
	tab:CreateToggle({ Name = "Resource ESP", CurrentValue = false, Flag = "res_esp_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateToggle({ Name = "Stone", CurrentValue = true, Flag = "res_esp_stone", Callback = function(v) showStone = v end })
	tab:CreateToggle({ Name = "Metal", CurrentValue = true, Flag = "res_esp_metal", Callback = function(v) showMetal = v end })
	tab:CreateToggle({ Name = "Sulfur", CurrentValue = true, Flag = "res_esp_sulfur", Callback = function(v) showSulfur = v end })
	tab:CreateToggle({ Name = "Wood", CurrentValue = true, Flag = "res_esp_wood", Callback = function(v) showWood = v end })
	tab:CreateSlider({ Name = "Max Distance", Range = {50, 2000}, Increment = 50, CurrentValue = 500, Flag = "res_esp_dist", Callback = function(v) maxDist = v end })

	local filters = { Stone = function() return showStone end, Metal = function() return showMetal end, Sulfur = function() return showSulfur end, Wood = function() return showWood end }

	local function classifyResource(name)
		local lower = string.lower(name)
		if string.find(lower, "sulfur") then return "Sulfur" end
		if string.find(lower, "metal") then return "Metal" end
		if string.find(lower, "stone") then return "Stone" end
		if string.find(lower, "wood") or string.find(lower, "tree") then return "Wood" end
		for kw in pairs(RESOURCE_KEYWORDS) do
			if string.find(lower, string.lower(kw)) then return kw end
		end
		return nil
	end

	local function scan()
		local now = tick()
		if now - scanTick < 0.5 then return scanCache end
		scanTick = now
		scanCache = {}
		local count = 0
		for _, inst in ipairs(workspace:GetDescendants()) do
			if count > 4000 then break end
			count += 1
			if inst:IsA("Model") then
				local hasSpark = inst:FindFirstChild("Spark") or inst:FindFirstChild("ServerSideHitbox")
				local kind = classifyResource(inst.Name)
				if kind or hasSpark then
					table.insert(scanCache, { inst = inst, kind = kind or "Stone" })
				end
			end
		end
		return scanCache
	end

	R.onHeartbeat("resource_esp", function()
		if not enabled then return end
		local hrp = S.HRP()
		if not hrp then return end

		local items = scan()
		local seen = {}

		for _, entry in ipairs(items) do
			local inst = entry.inst
			local kind = entry.kind
			if U.alive(inst) then
				local filterFn = filters[kind]
				if not filterFn or filterFn() then
					local pos = U.positionOf(inst)
					if pos and (pos - hrp.Position).Magnitude <= maxDist then
						seen[inst] = true
						local color = COLORS[kind] or Color3.fromRGB(200, 200, 200)
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
	end
end

return Feature
