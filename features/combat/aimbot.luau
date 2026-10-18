local Feature = {}
Feature.name = "Aimbot"
Feature.group = "Combat"

local enabled = false
local aimKey = Enum.KeyCode.C
local hitbox = "Head"
local fov = 200
local teamCheck = true
local visCheck = false
local smoothing = 5
local predictTarget = false
local currentTarget = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("Aimbot")
	tab:CreateToggle({ Name = "Aimbot", CurrentValue = false, Flag = "aimbot_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateKeybind({ Name = "Aim Key", CurrentKeybind = "C", HoldToInteract = true, Flag = "aimbot_key", Callback = function() end })
	tab:CreateDropdown({ Name = "Hitbox", Options = {"Head", "Chest", "Spine"}, CurrentOption = {"Head"}, Flag = "aimbot_hitbox", Callback = function(v) hitbox = v end })
	tab:CreateSlider({ Name = "FOV (px)", Range = {50, 800}, Increment = 10, CurrentValue = 200, Flag = "aimbot_fov", Callback = function(v) fov = v end })
	tab:CreateSlider({ Name = "Smoothing", Range = {1, 20}, Increment = 1, CurrentValue = 5, Flag = "aimbot_smooth", Callback = function(v) smoothing = v end })
	tab:CreateToggle({ Name = "Team Check", CurrentValue = true, Flag = "aimbot_team", Callback = function(v) teamCheck = v end })
	tab:CreateToggle({ Name = "Visible Check", CurrentValue = false, Flag = "aimbot_vis", Callback = function(v) visCheck = v end })
	tab:CreateToggle({ Name = "Target Prediction", CurrentValue = false, Flag = "aimbot_predict", Callback = function(v) predictTarget = v end })

	local fovCircle = U.newDrawing("Circle", { Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Filled = false, Radius = fov, NumSides = 64 })

	local function getTeam(player)
		return U.try(function() return player.CustomTeam.Value end) or 0
	end

	local function isFriendly(player)
		if not teamCheck then return false end
		local myTeam = getTeam(S.LocalPlayer)
		if myTeam == 0 then return false end
		return getTeam(player) == myTeam
	end

	local function isVisible(part)
		if not visCheck then return true end
		local cam = S.Camera()
		if not cam or not part then return true end
		local origin = cam.CFrame.Position
		local dir = (part.Position - origin)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { S.Character() }
		local result = workspace:Raycast(origin, dir, params)
		if not result then return true end
		return result.Instance:IsDescendantOf(part.Parent)
	end

	local function getBestTarget()
		local cam = S.Camera()
		if not cam then return nil, nil end
		local vs = cam.ViewportSize
		local center = Vector2.new(vs.X / 2, vs.Y / 2)
		local best, bestDist, bestPart = nil, fov, nil

		for _, player in ipairs(S.Players:GetPlayers()) do
			if player ~= S.LocalPlayer and not isFriendly(player) then
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					local part = U.hitPart(char, hitbox)
					if part then
						local v, onScreen = U.worldToViewport(part.Position)
						if onScreen then
							local screenDist = (Vector2.new(v.X, v.Y) - center).Magnitude
							if screenDist < bestDist and isVisible(part) then
								best = player
								bestDist = screenDist
								bestPart = part
							end
						end
					end
				end
			end
		end
		return best, bestPart
	end

	local function predictPosition(part)
		if not predictTarget or not part then return part.Position end
		local hrp = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
		if not hrp then return part.Position end
		local vel = U.try(function() return hrp.AssemblyLinearVelocity end) or Vector3.zero
		local myHRP = S.HRP()
		if not myHRP then return part.Position end
		local dist = (part.Position - myHRP.Position).Magnitude
		local Ballistics = Rem.Ballistics()
		local muzzleSpeed = 900
		if Ballistics and Ballistics.GetConfig then
			local cfg = U.try(function() return Ballistics:GetConfig() end)
			if cfg then muzzleSpeed = cfg.MuzzleVelocity or 900 end
		end
		local t = dist / muzzleSpeed
		return part.Position + vel * t
	end

	R.onRender("aimbot", function(dt)
		if fovCircle then
			local cam = S.Camera()
			if cam then
				local vs = cam.ViewportSize
				fovCircle.Position = Vector2.new(vs.X / 2, vs.Y / 2)
				fovCircle.Radius = fov
				fovCircle.Visible = enabled
			end
		end

		if not enabled then return end
		local uis = S.UserInputService
		if not uis:IsKeyDown(aimKey) then return end

		local target, part = getBestTarget()
		if not target or not part then return end

		local cam = S.Camera()
		if not cam then return end

		local aimPos = predictPosition(part)
		local targetCF = CFrame.lookAt(cam.CFrame.Position, aimPos)
		local alpha = math.clamp(dt * smoothing * 5, 0, 1)
		cam.CFrame = cam.CFrame:Lerp(targetCF, alpha)
	end)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
