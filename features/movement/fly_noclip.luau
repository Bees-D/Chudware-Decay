local Feature = {}
Feature.name = "Fly & Noclip"
Feature.group = "Movement"

local flyEnabled = false
local noclipEnabled = false
local flySpeed = 2
local bodyVel = nil
local bodyGyro = nil
local cachedCollisions = {}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Fly & Noclip")
	tab:CreateToggle({ Name = "Fly [ANTICHEAT RISK]", CurrentValue = false, Flag = "fly_toggle", Callback = function(v)
		flyEnabled = v
		if not v then cleanupFly() end
	end })
	tab:CreateSlider({ Name = "Fly Speed", Range = {0.5, 10}, Increment = 0.5, CurrentValue = 2, Flag = "fly_speed", Callback = function(v) flySpeed = v end })
	tab:CreateToggle({ Name = "Noclip [ANTICHEAT RISK]", CurrentValue = false, Flag = "noclip_toggle", Callback = function(v)
		noclipEnabled = v
		if not v then restoreCollisions() end
	end })

	function cleanupFly()
		if bodyVel then pcall(function() bodyVel:Destroy() end); bodyVel = nil end
		if bodyGyro then pcall(function() bodyGyro:Destroy() end); bodyGyro = nil end
		local hum = S.Humanoid()
		if hum then pcall(function() hum.PlatformStand = false end) end
	end

	function restoreCollisions()
		for part, orig in pairs(cachedCollisions) do
			pcall(function() part.CanCollide = orig end)
		end
		cachedCollisions = {}
	end

	R.onRender("fly_noclip", function(dt)
		local char = S.Character()
		local hrp = S.HRP()
		local hum = S.Humanoid()
		if not char or not hrp or not hum then return end

		if flyEnabled then
			hum.PlatformStand = true
			if not bodyVel or not U.alive(bodyVel) then
				bodyVel = Instance.new("BodyVelocity")
				bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
				bodyVel.Velocity = Vector3.zero
				bodyVel.Parent = hrp
			end
			if not bodyGyro or not U.alive(bodyGyro) then
				bodyGyro = Instance.new("BodyGyro")
				bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
				bodyGyro.P = 1e4
				bodyGyro.Parent = hrp
			end

			local cam = S.Camera()
			local uis = S.UserInputService
			local dir = Vector3.zero
			if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if uis:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0, 1, 0) end
			if uis:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0, 1, 0) end

			bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed * 50 or Vector3.zero
			bodyGyro.CFrame = cam.CFrame
		end

		if noclipEnabled then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					if cachedCollisions[part] == nil then cachedCollisions[part] = part.CanCollide end
					part.CanCollide = false
				end
			end
		end
	end)
end

function Feature.toggle(state) end

return Feature
