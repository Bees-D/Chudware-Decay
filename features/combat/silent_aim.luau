local Feature = {}
Feature.name = "Silent Aim"
Feature.group = "Combat"

local enabled = false
local hitbox = "Head"
local fovSilent = 300
local teamCheck = true
local origNamecall = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("Silent Aim")
	tab:CreateToggle({ Name = "Silent Aim", CurrentValue = false, Flag = "silent_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateDropdown({ Name = "Hitbox", Options = {"Head", "Chest", "Spine"}, CurrentOption = {"Head"}, Flag = "silent_hitbox", Callback = function(v) hitbox = v end })
	tab:CreateSlider({ Name = "FOV (px)", Range = {50, 800}, Increment = 10, CurrentValue = 300, Flag = "silent_fov", Callback = function(v) fovSilent = v end })
	tab:CreateToggle({ Name = "Team Check", CurrentValue = true, Flag = "silent_team", Callback = function(v) teamCheck = v end })

	local function getTeam(player)
		return U.try(function() return player.CustomTeam.Value end) or 0
	end

	local function isFriendly(player)
		if not teamCheck then return false end
		local myTeam = getTeam(S.LocalPlayer)
		if myTeam == 0 then return false end
		return getTeam(player) == myTeam
	end

	local function getBestTarget()
		local cam = S.Camera()
		if not cam then return nil end
		local vs = cam.ViewportSize
		local center = Vector2.new(vs.X / 2, vs.Y / 2)
		local best, bestDist, bestPart = nil, fovSilent, nil

		for _, player in ipairs(S.Players:GetPlayers()) do
			if player ~= S.LocalPlayer and not isFriendly(player) then
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					local part = U.hitPart(char, hitbox)
					if part then
						local v, onScreen = U.worldToViewport(part.Position)
						if onScreen then
							local d = (Vector2.new(v.X, v.Y) - center).Magnitude
							if d < bestDist then best = player; bestDist = d; bestPart = part end
						end
					end
				end
			end
		end
		return bestPart
	end

	local function hookShotHit()
		if not U.caps.getrawmeta then return end
		local mt = getrawmetatable(game)
		if not mt then return end
		local oldNamecall = mt.__namecall
		local setRO = setreadonly or make_writeable
		if not setRO then return end

		pcall(function()
			setRO(mt, false)
			mt.__namecall = newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if method == "FireServer" and enabled then
					local shotHit = Rem.ShotHit()
					if shotHit and self == shotHit then
						local args = {...}
						local target = getBestTarget()
						if target and args[1] and type(args[1]) == "table" then
							for _, entry in ipairs(args[1]) do
								if type(entry) == "table" then
									entry.Part = target
									entry.Position = target.Position
								end
							end
						end
						return oldNamecall(self, unpack(args))
					end
				end
				return oldNamecall(self, ...)
			end)
			setRO(mt, true)
		end)
		origNamecall = oldNamecall
	end

	task.defer(hookShotHit)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
