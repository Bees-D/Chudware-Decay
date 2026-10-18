local Feature = {}
Feature.name = "Fast Swing"
Feature.group = "Misc"

local enabled = false
local swingsPerSec = 5
local swingConn = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("Fast Swing")
	tab:CreateToggle({ Name = "Fast Swing [Server may rate-limit]", CurrentValue = false, Flag = "fswing_toggle", Callback = function(v) Feature.toggle(v) end })
	tab:CreateSlider({ Name = "Swings/sec", Range = {2, 20}, Increment = 1, CurrentValue = 5, Flag = "fswing_rate", Callback = function(v) swingsPerSec = v end })
	tab:CreateKeybind({ Name = "Swing Key", CurrentKeybind = "R", HoldToInteract = true, Flag = "fswing_key", Callback = function() end })

	local lastSwing = 0

	R.onHeartbeat("fast_swing", function()
		if not enabled then return end
		local uis = S.UserInputService
		if not uis:IsKeyDown(Enum.KeyCode.R) then return end

		local now = tick()
		if now - lastSwing < 1 / swingsPerSec then return end
		lastSwing = now

		local char = S.Character()
		if not char then return end
		local tool = char:FindFirstChildOfClass("Tool")
		local itemName = tool and tool.Name or "Rock"
		local itemType = "Tool"

		local ItemData = Rem.ItemData()
		if ItemData and ItemData.Items and ItemData.Items[itemName] then
			itemType = ItemData.Items[itemName].Type or "Tool"
		end

		local swingRemote = Rem.Swing()
		local attackRemote = Rem.Attack()

		if swingRemote then Rem.fireServer(swingRemote) end
		if attackRemote then Rem.fireServer(attackRemote, itemName, itemType) end
	end)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
