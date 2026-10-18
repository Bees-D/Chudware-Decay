local Feature = {}
Feature.name = "High Jump & Spider Climb"
Feature.group = "Movement"

local highJumpEnabled = false
local spiderEnabled = false
local jumpPower = 100
local climbSpeed = 30
local origJumpPower = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Jump & Climb")
	tab:CreateToggle({ Name = "High Jump", CurrentValue = false, Flag = "hjump_toggle", Callback = function(v)
		highJumpEnabled = v
		local hum = S.Humanoid()
		if hum then
			if v then
				origJumpPower = origJumpPower or hum.JumpPower
				hum.UseJumpPower = true
				hum.JumpPower = jumpPower
			elseif origJumpPower then
				hum.JumpPower = origJumpPower
			end
		end
	end })
	tab:CreateSlider({ Name = "Jump Power", Range = {50, 500}, Increment = 10, CurrentValue = 100, Flag = "hjump_power", Callback = function(v)
		jumpPower = v
		if highJumpEnabled then
			local hum = S.Humanoid()
			if hum then hum.JumpPower = v end
		end
	end })
	tab:CreateToggle({ Name = "Spider Climb", CurrentValue = false, Flag = "spider_toggle", Callback = function(v) spiderEnabled = v end })
	tab:CreateSlider({ Name = "Climb Speed", Range = {10, 100}, Increment = 5, CurrentValue = 30, Flag = "spider_speed", Callback = function(v) climbSpeed = v end })

	R.onRender("spider_climb", function(dt)
		if not spiderEnabled then return end
		local hrp = S.HRP()
		local hum = S.Humanoid()
		if not hrp or not hum then return end

		local uis = S.UserInputService
		if not uis:IsKeyDown(Enum.KeyCode.Space) then return end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { S.Character() }
		local ray = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, params)
		if ray then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, climbSpeed * dt, 0)
		end
	end)
end

function Feature.toggle(state) end

return Feature
