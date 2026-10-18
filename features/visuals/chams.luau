local Feature = {}
Feature.name = "Chams"
Feature.group = "Visuals"

local enabled = false
local fillColor = Color3.fromRGB(255, 0, 100)
local outlineColor = Color3.fromRGB(255, 255, 255)
local fillTransparency = 0.5
local teamColors = true
local highlights = {}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Chams")
	tab:CreateToggle({ Name = "Chams", CurrentValue = false, Flag = "chams_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateColorPicker({ Name = "Fill Color", Color = fillColor, Flag = "chams_fill", Callback = function(v) fillColor = v end })
	tab:CreateColorPicker({ Name = "Outline Color", Color = outlineColor, Flag = "chams_outline", Callback = function(v) outlineColor = v end })
	tab:CreateSlider({ Name = "Fill Transparency", Range = {0, 100}, Increment = 5, CurrentValue = 50, Flag = "chams_fillt", Callback = function(v) fillTransparency = v / 100 end })
	tab:CreateToggle({ Name = "Team Colors", CurrentValue = true, Flag = "chams_team", Callback = function(v) teamColors = v end })

	local function getTeam(player)
		return U.try(function() return player.CustomTeam.Value end) or 0
	end

	R.onHeartbeat("chams", function()
		if not enabled then return end
		local myTeam = getTeam(S.LocalPlayer)
		local seen = {}

		for _, player in ipairs(S.Players:GetPlayers()) do
			if player ~= S.LocalPlayer then
				local char = player.Character
				if char and U.alive(char) then
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						seen[char] = true
						local friendly = myTeam ~= 0 and getTeam(player) == myTeam
						local fc = teamColors and (friendly and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)) or fillColor
						local oc = teamColors and fc or outlineColor
						U.setHighlight(char, { FillColor = fc, FillTransparency = fillTransparency, OutlineColor = oc, OutlineTransparency = 0 })
						highlights[char] = true
					end
				end
			end
		end

		for inst in pairs(highlights) do
			if not seen[inst] then U.clearHighlight(inst); highlights[inst] = nil end
		end
	end)
end

function Feature.toggle(state)
	enabled = state
	if not state then
		for inst in pairs(highlights) do U.clearHighlight(inst) end
		highlights = {}
	end
end

return Feature
