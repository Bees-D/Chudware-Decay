local Feature = {}
Feature.name = "Material Farm Bot"
Feature.group = "Misc"

local enabled = false
local homePos = nil
local nodeFilter = "all"
local stopOnThreat = true
local botState = "IDLE"

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("Auto Farm Bot")
	tab:CreateToggle({ Name = "Auto Farm Bot", CurrentValue = false, Flag = "matbot_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateDropdown({ Name = "Node Filter", Options = {"all", "Stone", "Metal", "Sulfur", "Wood"}, CurrentOption = {"all"}, Flag = "matbot_filter", Callback = function(v) nodeFilter = v end })
	tab:CreateToggle({ Name = "Stop on Threat", CurrentValue = true, Flag = "matbot_threat", Callback = function(v) stopOnThreat = v end })
	tab:CreateButton({ Name = "Set Home Position", Callback = function()
		local hrp = S.HRP()
		if hrp then
			homePos = hrp.Position
			ctx.notify("Farm Bot", "Home set at " .. tostring(math.floor(homePos.X)) .. ", " .. tostring(math.floor(homePos.Z)))
		end
	end })

	local RESOURCE_KW = { Stone = true, Metal = true, Sulfur = true, Wood = true, Tree = true, Ore = true, Node = true }

	local function classifyNode(name)
		local lower = string.lower(name)
		if string.find(lower, "sulfur") then return "Sulfur" end
		if string.find(lower, "metal") then return "Metal" end
		if string.find(lower, "stone") then return "Stone" end
		if string.find(lower, "wood") or string.find(lower, "tree") then return "Wood" end
		return nil
	end

	local function findNearestNode()
		local hrp = S.HRP()
		if not hrp then return nil end
		local best, bestDist = nil, math.huge
		for _, inst in ipairs(workspace:GetDescendants()) do
			if inst:IsA("Model") then
				local kind = classifyNode(inst.Name)
				if kind and (nodeFilter == "all" or nodeFilter == kind) then
					local pos = U.positionOf(inst)
					if pos then
						local d = (pos - hrp.Position).Magnitude
						if d < bestDist then best = inst; bestDist = d end
					end
				end
			end
		end
		return best
	end

	local function isNearby(pos, range)
		local hrp = S.HRP()
		return hrp and (hrp.Position - pos).Magnitude < range
	end

	local function threatNearby()
		if not stopOnThreat then return false end
		local hrp = S.HRP()
		if not hrp then return false end
		local myTeam = U.try(function() return S.LocalPlayer.CustomTeam.Value end) or 0
		for _, p in ipairs(S.Players:GetPlayers()) do
			if p ~= S.LocalPlayer then
				local pTeam = U.try(function() return p.CustomTeam.Value end) or 0
				if myTeam == 0 or pTeam ~= myTeam then
					local char = p.Character
					local phrp = char and char:FindFirstChild("HumanoidRootPart")
					if phrp and (phrp.Position - hrp.Position).Magnitude < 80 then return true end
				end
			end
		end
		return false
	end

	local swingTick = 0

	R.onHeartbeat("material_bot", function()
		if not enabled then botState = "IDLE"; return end
		local hum = S.Humanoid()
		local hrp = S.HRP()
		if not hum or not hrp then return end

		if threatNearby() then botState = "THREAT"; return end

		if botState == "IDLE" or botState == "THREAT" then
			botState = "FIND"
		end

		if botState == "FIND" then
			local node = findNearestNode()
			if node then
				local pos = U.positionOf(node)
				if pos then
					hum:MoveTo(pos)
					botState = "MOVE"
				end
			end
		end

		if botState == "MOVE" then
			local node = findNearestNode()
			if node then
				local pos = U.positionOf(node)
				if pos and isNearby(pos, 8) then
					botState = "SWING"
				elseif pos then
					hum:MoveTo(pos)
				else
					botState = "FIND"
				end
			else
				botState = "FIND"
			end
		end

		if botState == "SWING" then
			local now = tick()
			if now - swingTick > 0.4 then
				swingTick = now
				local swingRemote = Rem.Swing()
				local attackRemote = Rem.Attack()
				local char = S.Character()
				local tool = char and char:FindFirstChildOfClass("Tool")
				local name = tool and tool.Name or "Rock"
				if swingRemote then Rem.fireServer(swingRemote) end
				if attackRemote then Rem.fireServer(attackRemote, name, "Tool") end
			end
			local node = findNearestNode()
			if not node or not U.alive(node) then botState = "FIND" end
		end
	end)
end

function Feature.toggle(state)
	enabled = state
	if not state then botState = "IDLE" end
end

return Feature
