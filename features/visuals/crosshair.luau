local Feature = {}
Feature.name = "Crosshair"
Feature.group = "Visuals"

local enabled = false
local crossColor = Color3.fromRGB(0, 255, 0)
local crossSize = 12
local crossGap = 4
local crossThickness = 1.5
local showDot = true
local lines = {}
local dot = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Crosshair")
	tab:CreateToggle({ Name = "Custom Crosshair", CurrentValue = false, Flag = "xhair_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateColorPicker({ Name = "Color", Color = crossColor, Flag = "xhair_color", Callback = function(v) crossColor = v; updateColor() end })
	tab:CreateSlider({ Name = "Size", Range = {4, 40}, Increment = 1, CurrentValue = 12, Flag = "xhair_size", Callback = function(v) crossSize = v end })
	tab:CreateSlider({ Name = "Gap", Range = {0, 20}, Increment = 1, CurrentValue = 4, Flag = "xhair_gap", Callback = function(v) crossGap = v end })
	tab:CreateToggle({ Name = "Center Dot", CurrentValue = true, Flag = "xhair_dot", Callback = function(v) showDot = v end })

	local function create()
		if #lines > 0 then return end
		for i = 1, 4 do
			local l = U.newDrawing("Line", { Thickness = crossThickness, Color = crossColor })
			table.insert(lines, l)
		end
		dot = U.newDrawing("Circle", { Thickness = 1, Color = crossColor, Filled = true, Radius = 2 })
	end

	function updateColor()
		for _, l in ipairs(lines) do if l then pcall(function() l.Color = crossColor end) end end
		if dot then pcall(function() dot.Color = crossColor end) end
	end

	R.onRender("crosshair", function()
		if not enabled then return end
		create()
		local cam = S.Camera()
		if not cam then return end
		local vs = cam.ViewportSize
		local cx, cy = vs.X / 2, vs.Y / 2

		if lines[1] then lines[1].From = Vector2.new(cx - crossGap - crossSize, cy); lines[1].To = Vector2.new(cx - crossGap, cy); lines[1].Color = crossColor; lines[1].Visible = true end
		if lines[2] then lines[2].From = Vector2.new(cx + crossGap, cy); lines[2].To = Vector2.new(cx + crossGap + crossSize, cy); lines[2].Color = crossColor; lines[2].Visible = true end
		if lines[3] then lines[3].From = Vector2.new(cx, cy - crossGap - crossSize); lines[3].To = Vector2.new(cx, cy - crossGap); lines[3].Color = crossColor; lines[3].Visible = true end
		if lines[4] then lines[4].From = Vector2.new(cx, cy + crossGap); lines[4].To = Vector2.new(cx, cy + crossGap + crossSize); lines[4].Color = crossColor; lines[4].Visible = true end

		if dot then
			dot.Position = Vector2.new(cx, cy)
			dot.Color = crossColor
			dot.Visible = showDot
		end
	end)
end

function Feature.toggle(state)
	enabled = state
	if not state then
		for _, l in ipairs(lines) do U.hideDrawing(l) end
		if dot then pcall(function() dot.Visible = false end) end
	end
end

return Feature
