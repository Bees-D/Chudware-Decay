local Feature = {}
Feature.name = "No Recoil"
Feature.group = "Combat"

local enabled = false
local strength = 100
local origGetRecoil = nil

function Feature.init(tab, ctx)
	local U = ctx.util
	local Rem = ctx.remotes
	local R = ctx.runtime
	local S = ctx.services

	tab:CreateSection("Recoil")
	tab:CreateToggle({ Name = "No Recoil", CurrentValue = false, Flag = "norecoil_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Strength %", Range = {0, 100}, Increment = 5, CurrentValue = 100, Flag = "norecoil_str", Callback = function(v) strength = v end })

	local hooked = false
	local preShotCF = nil

	local function tryHook()
		if hooked then return true end
		if not U.caps.hookfunction then return false end
		local RC = Rem.RecoilConfig()
		if not RC or not RC.GetRecoil then return false end
		origGetRecoil = hookfunction(RC.GetRecoil, function(...)
			if enabled then
				local result = origGetRecoil(...)
				if typeof(result) == "Vector3" then
					local mult = 1 - (strength / 100)
					return result * mult
				end
				return result
			end
			return origGetRecoil(...)
		end)
		hooked = true
		return true
	end

	R.onRender("norecoil_fallback", function(dt)
		if not enabled then preShotCF = nil; return end
		if hooked then return end
		local cam = S.Camera()
		if not cam then return end
		if not preShotCF then preShotCF = cam.CFrame; return end
		local diff = preShotCF:ToObjectSpace(cam.CFrame)
		local rx, ry, rz = diff:ToEulerAnglesXYZ()
		local mult = strength / 100
		cam.CFrame = cam.CFrame * CFrame.Angles(-rx * mult * dt * 10, -ry * mult * dt * 10, 0)
		preShotCF = cam.CFrame
	end)

	task.defer(tryHook)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
