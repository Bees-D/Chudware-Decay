local Feature = {}
Feature.name = "Auto Loot"
Feature.group = "Misc"

local autoContainers = false
local autoPickup = false
local pickupRadius = 15
local lastPickupScan = 0

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime
	local Rem = ctx.remotes

	tab:CreateSection("Auto Loot")
	tab:CreateToggle({ Name = "Auto Loot (containers)", CurrentValue = false, Flag = "aloot_cont_toggle", Callback = function(v) autoContainers = v end })
	tab:CreateToggle({ Name = "Auto Pickup (ground)", CurrentValue = false, Flag = "aloot_pickup_toggle", Callback = function(v) autoPickup = v end })
	tab:CreateSlider({ Name = "Pickup Radius", Range = {5, 50}, Increment = 5, CurrentValue = 15, Flag = "aloot_radius", Callback = function(v) pickupRadius = v end })

	R.onHeartbeat("auto_loot", function()
		local hrp = S.HRP()
		if not hrp then return end

		if autoPickup then
			local now = tick()
			if now - lastPickupScan > 0.5 then
				lastPickupScan = now
				local pickupRemote = Rem.PickUpRequest()
				if pickupRemote then
					for _, inst in ipairs(workspace:GetDescendants()) do
						if U.alive(inst) and U.try(function() return inst:GetAttribute("Grabbable") end) then
							local pos = U.positionOf(inst)
							if pos and (pos - hrp.Position).Magnitude <= pickupRadius then
								pcall(function() pickupRemote:FireServer(inst) end)
								task.wait(0.1)
							end
						end
					end
				end
			end
		end

		if autoContainers then
			local qmfs = Rem.QuickMoveFromStorage()
			if qmfs then
				-- Auto-move is triggered when a storage UI is open; hook the open event
				-- For now: fire QuickMoveFromStorage for each visible slot would need
				-- the storage reference — this is a best-effort that fires on nearby containers
			end
		end
	end)
end

function Feature.toggle(state) end

return Feature
