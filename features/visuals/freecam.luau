local Feature = {}
Feature.name = "Freecam"
Feature.group = "Visuals"

local enabled = false
local speed = 1
local origCamType = nil
local origCamCF = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Freecam")
	tab:CreateToggle({ Name = "Freecam", CurrentValue = false, Flag = "freecam_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Speed", Range = {0.5, 10}, Increment = 0.5, CurrentValue = 1, Flag = "freecam_speed", Callback = function(v) speed = v end })
	tab:CreateKeybind({ Name = "Freecam Key", CurrentKeybind = "P", HoldToInteract = false, Flag = "freecam_key", Callback = function()
		Feature.toggle(not enabled)
	end })

	R.onRender("freecam", function(dt)
		if not enabled then return end
		local cam = S.Camera()
		if not cam then return end

		cam.CameraType = Enum.CameraType.Scriptable

		local moveDir = Vector3.zero
		local uis = S.UserInputService
		if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.E) then moveDir += Vector3.new(0, 1, 0) end
		if uis:IsKeyDown(Enum.KeyCode.Q) then moveDir -= Vector3.new(0, 1, 0) end

		if moveDir.Magnitude > 0 then
			cam.CFrame = cam.CFrame + moveDir.Unit * speed * dt * 60
		end
	end)
end

function Feature.toggle(state)
	local cam = workspace.CurrentCamera
	if state and not enabled then
		origCamType = cam.CameraType
		origCamCF = cam.CFrame
		cam.CameraType = Enum.CameraType.Scriptable
	elseif not state and enabled then
		if origCamType then cam.CameraType = origCamType end
		cam.CameraSubject = game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
	enabled = state
end

return Feature
