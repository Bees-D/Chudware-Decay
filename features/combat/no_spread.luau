local Feature = {}
Feature.name = "No Spread & No Sway"
Feature.group = "Combat"

local noSpreadEnabled = false
local noSwayEnabled = false
local origGetVelocities = nil
local lastCamCF = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("Spread & Sway")
	tab:CreateToggle({ Name = "No Spread", CurrentValue = false, Flag = "nospread_toggle", Callback = function(v) noSpreadEnabled = v end })
	tab:CreateToggle({ Name = "No Sway", CurrentValue = false, Flag = "nosway_toggle", Callback = function(v) noSwayEnabled = v end })

	local function tryHookSpread()
		if not U.caps.hookfunction then return end
		local Bal = Rem.Ballistics()
		if not Bal or not Bal.GetVelocities then return end
		origGetVelocities = hookfunction(Bal.GetVelocities, function(...)
			local result = origGetVelocities(...)
			if noSpreadEnabled and type(result) == "table" then
				local avgDir = nil
				local avgMag = 0
				local count = 0
				for _, v in ipairs(result) do
					if typeof(v) == "Vector3" then
						avgDir = avgDir and (avgDir + v.Unit) or v.Unit
						avgMag += v.Magnitude
						count += 1
					end
				end
				if avgDir and count > 0 then
					avgDir = avgDir.Unit
					avgMag = avgMag / count
					for i, v in ipairs(result) do
						if typeof(v) == "Vector3" then
							result[i] = avgDir * avgMag
						end
					end
				end
			end
			return result
		end)
	end

	R.onRender("nosway", function(dt)
		if not noSwayEnabled then lastCamCF = nil; return end
		local cam = S.Camera()
		if not cam then return end
		if lastCamCF then
			local _, _, _, _, _, _, _, _, _, m00, m01, m02 = lastCamCF:GetComponents()
			cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.new(0, 0, 0, select(4, lastCamCF:GetComponents()))
		end
		lastCamCF = cam.CFrame
	end)

	task.defer(tryHookSpread)
end

function Feature.toggle(state) end

return Feature
