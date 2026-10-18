local Feature = {}
Feature.name = "Base & Trap ESP"
Feature.group = "Visuals"

local enabled = false
local maxDist = 500
local showLocks = true
local showDoors = true
local showTraps = true
local showTurrets = true
local showWalls = true
local billboards = {}

local CLASSIFY = {
	["Code Lock"] = "lock", ["Key Lock"] = "lock",
	["Shotgun Trap"] = "trap", ["Flame Turret"] = "turret",
}

local function classify(name)
	if CLASSIFY[name] then return CLASSIFY[name] end
	if string.find(name, "Door") then return "door" end
	if string.find(name, "High External") then return "wall" end
	return "other"
end

local COLORS = {
	lock = Color3.fromRGB(255, 255, 0),
	door = Color3.fromRGB(180, 180, 180),
	trap = Color3.fromRGB(255, 80, 80),
	turret = Color3.fromRGB(255, 120, 0),
	wall = Color3.fromRGB(100, 200, 255),
	other = Color3.fromRGB(200, 200, 200),
}

local FILTER = { lock = "showLocks", door = "showDoors", trap = "showTraps", turret = "showTurrets", wall = "showWalls" }

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Base & Trap ESP")
	tab:CreateToggle({ Name = "Base/Trap ESP", CurrentValue = false, Flag = "base_esp_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateToggle({ Name = "Locks", CurrentValue = true, Flag = "base_esp_locks", Callback = function(v) showLocks = v end })
	tab:CreateToggle({ Name = "Doors", CurrentValue = true, Flag = "base_esp_doors", Callback = function(v) showDoors = v end })
	tab:CreateToggle({ Name = "Traps", CurrentValue = true, Flag = "base_esp_traps", Callback = function(v) showTraps = v end })
	tab:CreateToggle({ Name = "Turrets", CurrentValue = true, Flag = "base_esp_turrets", Callback = function(v) showTurrets = v end })
	tab:CreateToggle({ Name = "Walls/Gates", CurrentValue = true, Flag = "base_esp_walls", Callback = function(v) showWalls = v end })
	tab:CreateSlider({ Name = "Max Distance", Range = {50, 1500}, Increment = 50, CurrentValue = 500, Flag = "base_esp_dist", Callback = function(v) maxDist = v end })

	local filters = { lock = function() return showLocks end, door = function() return showDoors end, trap = function() return showTraps end, turret = function() return showTurrets end, wall = function() return showWalls end }

	local function makeBB(part, color)
		local bb = Instance.new("BillboardGui")
		bb.Name = "ChudBase"
		bb.Adornee = part
		bb.Size = UDim2.new(0, 160, 0, 30)
		bb.StudsOffset = Vector3.new(0, 3, 0)
		bb.AlwaysOnTop = true
		bb.Parent = part
		local lbl = Instance.new("TextLabel")
		lbl.Name = "Info"
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = color
		lbl.TextStrokeTransparency = 0.3
		lbl.TextScaled = true
		lbl.Font = Enum.Font.GothamBold
		lbl.Parent = bb
		return bb
	end

	R.onHeartbeat("base_esp", function()
		if not enabled then return end
		local hrp = S.HRP()
		if not hrp then return end

		local deployables = U.try(function() return workspace.PlayerBuiltStructures.Deployables:GetChildren() end)
		if not deployables then return end

		local seen = {}
		for _, model in ipairs(deployables) do
			if U.alive(model) then
				local cat = classify(model.Name)
				local filterFn = filters[cat]
				if not filterFn or filterFn() then
					local pos = U.positionOf(model)
					if pos and (pos - hrp.Position).Magnitude <= maxDist then
						seen[model] = true
						if not billboards[model] or not U.alive(billboards[model]) then
							local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
							if part then billboards[model] = makeBB(part, COLORS[cat] or COLORS.other) end
						end
						local bb = billboards[model]
						if bb then
							local lbl = bb:FindFirstChild("Info")
							if lbl then
								local hp = U.try(function() return model.Health.Value end) or "?"
								local dist = math.floor((pos - hrp.Position).Magnitude)
								lbl.Text = model.Name .. "  HP:" .. tostring(hp) .. "  [" .. dist .. "m]"
								lbl.TextColor3 = COLORS[cat] or COLORS.other
							end
						end
					end
				end
			end
		end

		for model, bb in pairs(billboards) do
			if not seen[model] then
				pcall(function() bb:Destroy() end)
				billboards[model] = nil
			end
		end
	end)
end

function Feature.toggle(state)
	enabled = state
	if not state then
		for _, bb in pairs(billboards) do pcall(function() bb:Destroy() end) end
		billboards = {}
	end
end

return Feature
