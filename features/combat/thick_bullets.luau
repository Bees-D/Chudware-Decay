local Feature = {}
Feature.name = "Thick Bullets"
Feature.group = "Combat"

local enabled = false
local multiplier = 3
local origGetConfig = nil

function Feature.init(tab, ctx)
	local U = ctx.util
	local Rem = ctx.remotes

	tab:CreateSection("Thick Bullets")
	tab:CreateToggle({ Name = "Thick Bullets", CurrentValue = false, Flag = "thick_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Radius Multiplier", Range = {1, 8}, Increment = 0.5, CurrentValue = 3, Flag = "thick_mult", Callback = function(v) multiplier = v end })

	local function tryHook()
		if not U.caps.hookfunction then return end
		local Bal = Rem.Ballistics()
		if not Bal or not Bal.GetConfig then return end
		origGetConfig = hookfunction(Bal.GetConfig, function(...)
			local result = origGetConfig(...)
			if enabled and type(result) == "table" then
				result.HitRadius = (result.HitRadius or 0.1) * multiplier
			end
			return result
		end)
	end

	task.defer(tryHook)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
