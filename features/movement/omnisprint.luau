local Feature = {}
Feature.name = "Always Sprint"
Feature.group = "Movement"

local enabled = false
local sprintSpeed = 16.5

function Feature.init(tab, ctx)
	local S = ctx.services
	local R = ctx.runtime

	tab:CreateSection("Sprint")
	tab:CreateToggle({ Name = "Always Sprint", CurrentValue = false, Flag = "sprint_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Speed", Range = {12, 50}, Increment = 0.5, CurrentValue = 16.5, Flag = "sprint_speed", Callback = function(v) sprintSpeed = v end })

	R.onHeartbeat("omnisprint", function()
		if not enabled then return end
		local hum = S.Humanoid()
		if hum then
			pcall(function()
				if hum.WalkSpeed < sprintSpeed then hum.WalkSpeed = sprintSpeed end
			end)
		end
	end)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
