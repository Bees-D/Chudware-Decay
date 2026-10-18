local Feature = {}
Feature.name = "Fullbright"
Feature.group = "Visuals"

local enabled = false
local brightness = 3
local originals = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local R = ctx.runtime

	tab:CreateSection("Fullbright")
	tab:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "fullbright_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Brightness", Range = {1, 10}, Increment = 0.5, CurrentValue = 3, Flag = "fullbright_val", Callback = function(v) brightness = v end })

	local function capture()
		if originals then return end
		local L = S.Lighting
		originals = {
			Brightness = L.Brightness,
			Ambient = L.Ambient,
			OutdoorAmbient = L.OutdoorAmbient,
			ClockTime = L.ClockTime,
			FogEnd = L.FogEnd,
			EnvironmentDiffuseScale = L.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = L.EnvironmentSpecularScale,
		}
		local atm = L:FindFirstChildOfClass("Atmosphere")
		if atm then originals.AtmosphereDensity = atm.Density end
	end

	local function apply()
		local L = S.Lighting
		L.Brightness = brightness
		L.Ambient = Color3.new(1, 1, 1)
		L.OutdoorAmbient = Color3.new(1, 1, 1)
		L.ClockTime = 14
		L.FogEnd = 1e6
		L.EnvironmentDiffuseScale = 1
		L.EnvironmentSpecularScale = 1
		local atm = L:FindFirstChildOfClass("Atmosphere")
		if atm then pcall(function() atm.Density = 0 end) end
	end

	local function restore()
		if not originals then return end
		local L = S.Lighting
		for k, v in pairs(originals) do
			if k == "AtmosphereDensity" then
				local atm = L:FindFirstChildOfClass("Atmosphere")
				if atm then pcall(function() atm.Density = v end) end
			else
				pcall(function() L[k] = v end)
			end
		end
		originals = nil
	end

	R.onRender("fullbright", function()
		if not enabled then return end
		capture()
		apply()
	end)
end

function Feature.toggle(state)
	enabled = state
	if not state and originals then
		local S = game:GetService("Lighting")
		for k, v in pairs(originals) do
			if k == "AtmosphereDensity" then
				local atm = S:FindFirstChildOfClass("Atmosphere")
				if atm then pcall(function() atm.Density = v end) end
			else
				pcall(function() S[k] = v end)
			end
		end
		originals = nil
	end
end

return Feature
