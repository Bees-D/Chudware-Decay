--[[ core/util.luau — math/CFrame/raycast/highlight helpers + executor capability probing.
     Every game-touching helper is pcall-guarded; callers treat nil as "not available". ]]

local Services = _G._chud_modules and _G._chud_modules.services or require(script.Parent.services)

local Util = {}

-- ---- executor capability guards -------------------------------------------
-- Probe once; features self-disable when a capability is missing.
Util.caps = {
	hookfunction   = (type(hookfunction) == "function"),
	hookmetamethod = (type(hookmetamethod) == "function"),
	getrawmeta     = (type(getrawmetatable) == "function") and (type(setreadonly) == "function" or type(make_writeable) == "function"),
	drawing        = (type(Drawing) == "table" or type(Drawing) == "userdata"),
	fs             = (type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"),
}

function Util.canHook()
	return Util.caps.hookfunction or Util.caps.hookmetamethod
end

-- ---- generic -------------------------------------------------------------
function Util.alive(inst)
	-- true only for a non-destroyed, still-parented instance
	local ok, parent = pcall(function() return inst.Parent end)
	return ok and parent ~= nil
end

function Util.try(fn, ...)
	local ok, res = pcall(fn, ...)
	if ok then return res end
	return nil
end

-- ---- geometry ------------------------------------------------------------
function Util.worldToViewport(worldPos)
	local cam = Services.Camera()
	if not cam then return nil, false end
	local v, onScreen = cam:WorldToViewportPoint(worldPos)
	return v, onScreen and v.Z > 0
end

function Util.distanceFromLocal(worldPos)
	local hrp = Services.HRP()
	if not hrp then return math.huge end
	return (hrp.Position - worldPos).Magnitude
end

-- Primary position of any instance (Model PrimaryPart / BasePart / descendant part).
function Util.positionOf(inst)
	if not inst then return nil end
	if inst:IsA("BasePart") then return inst.Position end
	if inst:IsA("Model") then
		if inst.PrimaryPart then return inst.PrimaryPart.Position end
		local ok, cf = pcall(function() return inst:GetPivot() end)
		if ok then return cf.Position end
		local p = inst:FindFirstChildWhichIsA("BasePart", true)
		if p then return p.Position end
	end
	return nil
end

-- Character hitbox lookup with R15/R6 fallbacks. kind: "Head"|"Chest"|"Spine".
function Util.hitPart(character, kind)
	if not character then return nil end
	local order
	if kind == "Head" then
		order = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}
	elseif kind == "Spine" then
		order = {"LowerTorso", "Torso", "HumanoidRootPart", "UpperTorso"}
	else -- Chest
		order = {"UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso"}
	end
	for _, n in ipairs(order) do
		local p = character:FindFirstChild(n)
		if p and p:IsA("BasePart") then return p end
	end
	return character:FindFirstChildWhichIsA("BasePart")
end

-- ---- highlight registry --------------------------------------------------
local highlights = {} -- [adornee] = Highlight
function Util.setHighlight(adornee, props)
	if not Util.alive(adornee) then return end
	local hl = highlights[adornee]
	if not hl or not Util.alive(hl) then
		hl = Instance.new("Highlight")
		hl.Name = "ChudHL"
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Adornee = adornee
		hl.Parent = adornee
		highlights[adornee] = hl
	end
	for k, v in pairs(props) do
		pcall(function() hl[k] = v end)
	end
end

function Util.clearHighlight(adornee)
	local hl = highlights[adornee]
	if hl then pcall(function() hl:Destroy() end) end
	highlights[adornee] = nil
end

function Util.clearAllHighlights()
	for a, hl in pairs(highlights) do
		pcall(function() hl:Destroy() end)
		highlights[a] = nil
	end
end

-- ---- Drawing helpers (nil-safe when Drawing is unavailable) ---------------
function Util.newDrawing(class, props)
	if not Util.caps.drawing then return nil end
	local ok, d = pcall(function() return Drawing.new(class) end)
	if not ok or not d then return nil end
	if props then
		for k, v in pairs(props) do pcall(function() d[k] = v end) end
	end
	return d
end

function Util.hideDrawing(d) if d then pcall(function() d.Visible = false end) end end
function Util.destroyDrawing(d) if d then pcall(function() d:Remove() end) end end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.util = Util
return Util
