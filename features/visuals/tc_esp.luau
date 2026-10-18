local Feature = {}
Feature.name = "TC ESP"
Feature.group = "Visuals"

local enabled = false
local maxDist = 500
local espColor = Color3.fromRGB(255, 170, 0)
local billboards = {}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("TC / Base Claim ESP")
	tab:CreateToggle({ Name = "TC ESP", CurrentValue = false, Flag = "tc_esp_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Max Distance", Range = {50, 2000}, Increment = 50, CurrentValue = 500, Flag = "tc_esp_dist", Callback = function(v) maxDist = v end })
	tab:CreateColorPicker({ Name = "TC Color", Color = espColor, Flag = "tc_esp_color", Callback = function(v) espColor = v end })

	local function getMaxHP(name)
		local ItemData = Rem.ItemData()
		if ItemData and ItemData.Items and ItemData.Items[name] then
			return ItemData.Items[name].Health or 100
		end
		return 100
	end

	local function makeBB(model)
		local pp = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
		if not pp then return nil end
		local bb = Instance.new("BillboardGui")
		bb.Name = "ChudTC"
		bb.Adornee = pp
		bb.Size = UDim2.new(0, 200, 0, 60)
		bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.AlwaysOnTop = true
		bb.Parent = pp
		local lbl = Instance.new("TextLabel")
		lbl.Name = "Info"
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = espColor
		lbl.TextStrokeTransparency = 0.3
		lbl.TextScaled = true
		lbl.Font = Enum.Font.GothamBold
		lbl.Parent = bb
		return bb
	end

	R.onRender("tc_esp", function()
		if not enabled then return end
		local hrp = S.HRP()
		if not hrp then return end

		local deployables = U.try(function() return workspace.PlayerBuiltStructures.Deployables:GetChildren() end)
		if not deployables then return end

		local seen = {}
		for _, model in ipairs(deployables) do
			if U.alive(model) then
				local bc = model:FindFirstChild("BaseClaim")
				if not bc and model.Name == "Base Claim" then bc = true end
				if bc then
					local pos = U.positionOf(model)
					if pos and (pos - hrp.Position).Magnitude <= maxDist then
						seen[model] = true
						if not billboards[model] or not U.alive(billboards[model]) then
							billboards[model] = makeBB(model)
						end
						local bb = billboards[model]
						if bb then
							local lbl = bb:FindFirstChild("Info")
							if lbl then
								lbl.TextColor3 = espColor
								local hp = U.try(function() return model.Health.Value end) or "?"
								local maxHp = getMaxHP("Base Claim")
								local authCount = 0
								local authFolder = U.try(function()
									return model.BaseClaim.Value.AuthorizedPlayers
								end)
								if authFolder then authCount = #authFolder:GetChildren() end
								local dist = math.floor((pos - hrp.Position).Magnitude)
								lbl.Text = "TC  " .. tostring(hp) .. "/" .. tostring(maxHp) .. "  auth:" .. tostring(authCount) .. "  [" .. dist .. "m]"
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
