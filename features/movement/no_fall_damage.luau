local Feature = {}
Feature.name = "No Fall Damage"
Feature.group = "Movement"

local enabled = false

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Fall Damage")
	tab:CreateToggle({ Name = "No Fall Damage (best-effort)", CurrentValue = false, Flag = "nofall_toggle", Callback = function(v) Feature.toggle(v) end })

	R.onRender("nofall", function()
		if not enabled then return end
		local hrp = S.HRP()
		if not hrp then return end

		local vel = U.try(function() return hrp.AssemblyLinearVelocity end)
		if not vel then return end

		if vel.Y < -60 then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { S.Character() }
			local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), params)
			if ray then
				pcall(function()
					hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -10, vel.Z)
				end)
			end
		end
	end)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
