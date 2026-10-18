local Feature = {}
Feature.name = "Node Crit Assist"
Feature.group = "Misc"

local enabled = false
local activeSparks = {}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("Node Crit Assist")
	tab:CreateToggle({ Name = "Node Crit Assist", CurrentValue = false, Flag = "critassist_toggle", Callback = function(v) Feature.toggle(v) end })

	local spawnSpark = Rem.SpawnSpark()
	local removeSpark = Rem.RemoveSpark()
	local setHasSpark = Rem.SetHasSpark()

	if spawnSpark then
		R.track("spark_spawn", spawnSpark.OnClientEvent:Connect(function(cf, node)
			if cf and typeof(cf) == "CFrame" then
				activeSparks[node or cf] = cf.Position
			end
		end))
	end

	if removeSpark then
		R.track("spark_remove", removeSpark.OnClientEvent:Connect(function(node)
			activeSparks[node] = nil
		end))
	end

	R.onRender("crit_assist", function(dt)
		if not enabled then return end
		local cam = S.Camera()
		if not cam then return end

		local hrp = S.HRP()
		if not hrp then return end

		local bestPos, bestDist = nil, 20
		for key, pos in pairs(activeSparks) do
			local d = (pos - hrp.Position).Magnitude
			if d < bestDist then bestPos = pos; bestDist = d end
		end

		if bestPos then
			local targetCF = CFrame.lookAt(cam.CFrame.Position, bestPos)
			cam.CFrame = cam.CFrame:Lerp(targetCF, math.clamp(dt * 8, 0, 1))
		end
	end)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
