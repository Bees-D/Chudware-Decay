local Feature = {}
Feature.name = "Player & Sleeper ESP"
Feature.group = "Visuals"

local enabled = false
local showBox = true
local showHealth = true
local showName = true
local showDist = true
local showWeapon = true
local showTeamColor = true
local filterFriendly = false
local maxDist = 1000
local drawings = {}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Player & Sleeper ESP")
	tab:CreateToggle({ Name = "Player ESP", CurrentValue = false, Flag = "player_esp_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateToggle({ Name = "Boxes", CurrentValue = true, Flag = "player_esp_box", Callback = function(v) showBox = v end })
	tab:CreateToggle({ Name = "Health Bar", CurrentValue = true, Flag = "player_esp_hp", Callback = function(v) showHealth = v end })
	tab:CreateToggle({ Name = "Names", CurrentValue = true, Flag = "player_esp_name", Callback = function(v) showName = v end })
	tab:CreateToggle({ Name = "Distance", CurrentValue = true, Flag = "player_esp_dist", Callback = function(v) showDist = v end })
	tab:CreateToggle({ Name = "Weapon", CurrentValue = true, Flag = "player_esp_wpn", Callback = function(v) showWeapon = v end })
	tab:CreateToggle({ Name = "Team Colors", CurrentValue = true, Flag = "player_esp_team", Callback = function(v) showTeamColor = v end })
	tab:CreateToggle({ Name = "Hide Friendly", CurrentValue = false, Flag = "player_esp_filter", Callback = function(v) filterFriendly = v end })
	tab:CreateSlider({ Name = "Max Distance", Range = {50, 3000}, Increment = 50, CurrentValue = 1000, Flag = "player_esp_maxdist", Callback = function(v) maxDist = v end })

	local function getTeam(player)
		local ct = U.try(function() return player.CustomTeam.Value end)
		return ct or 0
	end

	local function isFriendly(player)
		local myTeam = getTeam(S.LocalPlayer)
		if myTeam == 0 then return false end
		return getTeam(player) == myTeam
	end

	local function getWeapon(char)
		if not char then return "" end
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then return tool.Name end
		return ""
	end

	local function ensureDrawings(key)
		if drawings[key] then return drawings[key] end
		local d = {
			box = U.newDrawing("Square", { Thickness = 1, Filled = false, Transparency = 1 }),
			name = U.newDrawing("Text", { Size = 13, Center = true, Outline = true, Font = 2 }),
			hp = U.newDrawing("Line", { Thickness = 2 }),
			hpBg = U.newDrawing("Line", { Thickness = 2, Color = Color3.new(0, 0, 0) }),
		}
		drawings[key] = d
		return d
	end

	local function hideAll(d)
		if not d then return end
		for _, obj in pairs(d) do U.hideDrawing(obj) end
	end

	local function destroyAll(d)
		if not d then return end
		for _, obj in pairs(d) do U.destroyDrawing(obj) end
	end

	R.onRender("player_esp", function()
		if not enabled then
			for _, d in pairs(drawings) do hideAll(d) end
			return
		end

		local cam = S.Camera()
		local hrp = S.HRP()
		if not cam or not hrp then
			for _, d in pairs(drawings) do hideAll(d) end
			return
		end

		local seen = {}
		for _, player in ipairs(S.Players:GetPlayers()) do
			if player ~= S.LocalPlayer then
				local char = player.Character
				local phrp = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if phrp and hum and hum.Health > 0 then
					local dist = (phrp.Position - hrp.Position).Magnitude
					if dist <= maxDist then
						if not (filterFriendly and isFriendly(player)) then
							local v, onScreen = U.worldToViewport(phrp.Position)
							if onScreen then
								seen[player.Name] = true
								local d = ensureDrawings(player.Name)
								local scaleFactor = 1 / (v.Z * math.tan(math.rad(cam.FieldOfView / 2)) * 2 / cam.ViewportSize.Y)
								local boxH = math.clamp(scaleFactor * 6, 10, 800)
								local boxW = boxH * 0.5
								local friendly = isFriendly(player)
								local color = (showTeamColor and friendly) and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)

								if showBox and d.box then
									d.box.Size = Vector2.new(boxW, boxH)
									d.box.Position = Vector2.new(v.X - boxW / 2, v.Y - boxH / 2)
									d.box.Color = color
									d.box.Visible = true
								elseif d.box then d.box.Visible = false end

								if showName and d.name then
									local txt = player.Name
									if showDist then txt = txt .. " [" .. math.floor(dist) .. "m]" end
									if showWeapon then
										local wpn = getWeapon(char)
										if wpn ~= "" then txt = txt .. " {" .. wpn .. "}" end
									end
									d.name.Text = txt
									d.name.Position = Vector2.new(v.X, v.Y - boxH / 2 - 16)
									d.name.Color = color
									d.name.Visible = true
								elseif d.name then d.name.Visible = false end

								if showHealth and d.hpBg and d.hp then
									local hpFrac = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
									local barX = v.X - boxW / 2 - 4
									d.hpBg.From = Vector2.new(barX, v.Y - boxH / 2)
									d.hpBg.To = Vector2.new(barX, v.Y + boxH / 2)
									d.hpBg.Visible = true
									d.hp.From = Vector2.new(barX, v.Y + boxH / 2)
									d.hp.To = Vector2.new(barX, v.Y + boxH / 2 - boxH * hpFrac)
									d.hp.Color = Color3.fromRGB(255 * (1 - hpFrac), 255 * hpFrac, 0)
									d.hp.Visible = true
								else
									if d.hpBg then d.hpBg.Visible = false end
									if d.hp then d.hp.Visible = false end
								end
							else
								hideAll(drawings[player.Name])
							end
						else
							hideAll(drawings[player.Name])
						end
					else
						hideAll(drawings[player.Name])
					end
				else
					hideAll(drawings[player.Name])
				end
			end
		end

		for key, d in pairs(drawings) do
			if not seen[key] then hideAll(d) end
		end
	end)
end

function Feature.toggle(state)
	enabled = state
	if not state then
		for _, d in pairs(drawings) do
			for _, obj in pairs(d) do
				U_hideDrawing = U_hideDrawing -- not in scope; use pcall
				pcall(function() obj.Visible = false end)
			end
		end
	end
end

return Feature
