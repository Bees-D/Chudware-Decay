local Feature = {}
Feature.name = "Vuln Test"
Feature.group = "Security"

local RS = game:GetService("ReplicatedStorage")

local VULNS = {
	{ cat = "CRITICAL", name = "Hardcoded Secret (ClickToMove)", kind = "leak", path = nil, test = function()
		local ok, mod = pcall(function()
			return game.Players.LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
				and game.Players.LocalPlayer.PlayerScripts.PlayerModule:FindFirstChild("ControlModule")
				and game.Players.LocalPlayer.PlayerScripts.PlayerModule.ControlModule:FindFirstChild("ClickToMoveController")
		end)
		return ok and mod ~= nil
	end },
	{ cat = "HIGH", name = "Admin UserId Check (ChatTags)", kind = "client-admin", test = function()
		local ok, s = pcall(function()
			return game.Players.LocalPlayer.PlayerScripts:FindFirstChild("ChatTags")
		end)
		return ok and s ~= nil
	end },
	{ cat = "HIGH", name = "Respawn Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS:FindFirstChild("DeathScreen") and RS.DeathScreen:FindFirstChild("Respawn") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "DropSlot Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.Inventory.RemoteEvents:FindFirstChild("DropSlot") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "ReskinItem Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.Deployables.RemoteEvents:FindFirstChild("ReskinItem") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "BuyFromVendor Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.Players:FindFirstChild("BuyFromVendor") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "BuyKit Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.Kits:FindFirstChild("BuyKit") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "UpgradeToHQM Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.BuildingSystem.RemoteEvents:FindFirstChild("UpgradeToHighQualityMetal") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "UpgradeToMetal Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.BuildingSystem.RemoteEvents:FindFirstChild("UpgradeToMetal") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "UpgradeToStone Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.BuildingSystem.RemoteEvents:FindFirstChild("UpgradeToStone") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "UpgradeToWood Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.BuildingSystem.RemoteEvents:FindFirstChild("UpgradeToWood") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "SpawnSpark Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.Resources.RemoteEvents:FindFirstChild("SpawnSpark") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "Admin.GiveItem Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.Admin:FindFirstChild("GiveItem") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "DropItem Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.LootSystem.RemoteEvents:FindFirstChild("DropItem") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "OilrigRespawn Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.LootSystem.RemoteEvents:FindFirstChild("OilrigRespawn") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "SupplyDropNotification", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.SupplyDrops:FindFirstChild("SupplyDropNotification") end)
		return ok and r ~= nil
	end },
	{ cat = "HIGH", name = "AddCharacter Remote", kind = "dupe-vector", test = function()
		local ok, r = pcall(function() return RS.Teams.RemoteEvents:FindFirstChild("AddCharacter") end)
		return ok and r ~= nil
	end },
	{ cat = "MEDIUM", name = "DecaySettingsRemote (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS:FindFirstChild("DecaySettingsRemote") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "MEDIUM", name = "CalculateCFrame (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS.Deployables.RemoteEvents:FindFirstChild("CalculateCFrame") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "MEDIUM", name = "CanOpenLock (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS.Deployables.RemoteEvents:FindFirstChild("CanOpenLock") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "MEDIUM", name = "GetModdedDataClient (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS.ItemData:FindFirstChild("GetModdedDataClient") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "MEDIUM", name = "GetGeneratedMapImage (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS.MapGeneration:FindFirstChild("GetGeneratedMapImage") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "MEDIUM", name = "WalkSpeed Client-Auth", kind = "stat_write", test = function()
		local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not hum then return false end
		local old = hum.WalkSpeed
		hum.WalkSpeed = old + 0.001
		local worked = (hum.WalkSpeed ~= old)
		hum.WalkSpeed = old
		return worked
	end },
	{ cat = "MEDIUM", name = "Teams.Create (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS.Teams.RemoteEvents:FindFirstChild("Create") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "MEDIUM", name = "Teams.Leave (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS.Teams.RemoteEvents:FindFirstChild("Leave") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "MEDIUM", name = "ToolSystem.GetSides (RF)", kind = "remotefunction", test = function()
		local ok, r = pcall(function() return RS.ToolSystem.RemoteEvents:FindFirstChild("GetSides") end)
		return ok and r ~= nil and r:IsA("RemoteFunction")
	end },
	{ cat = "LOW", name = "math.random Loot (LootSettings)", kind = "predictability", test = function()
		local ok, r = pcall(function() return RS:FindFirstChild("LootSettings") end)
		return ok and r ~= nil
	end },
}

function Feature.init(tab, ctx)
	tab:CreateSection("Vulnerability Scanner")

	local labels = {}
	local GREEN = Color3.fromRGB(0, 255, 100)
	local RED = Color3.fromRGB(255, 60, 60)

	for _, vuln in ipairs(VULNS) do
		local status = "..."
		local ok, result = pcall(vuln.test)
		if ok and result then
			status = "[HOOKED] " .. vuln.name
		else
			status = "[FAILED] " .. vuln.name
		end

		local color = (ok and result) and "rgb(0,255,100)" or "rgb(255,60,60)"
		local severity = vuln.cat
		local prefix = severity == "CRITICAL" and "!!!" or severity == "HIGH" and "!!" or severity == "MEDIUM" and "!" or "~"

		tab:CreateParagraph({
			Title = prefix .. " [" .. severity .. "] " .. vuln.kind,
			Content = status
		})
	end

	local passed, failed = 0, 0
	for _, vuln in ipairs(VULNS) do
		local ok, result = pcall(vuln.test)
		if ok and result then passed += 1 else failed += 1 end
	end

	tab:CreateParagraph({
		Title = "Summary",
		Content = tostring(passed) .. "/" .. tostring(#VULNS) .. " surfaces reachable. " .. tostring(failed) .. " not found/blocked."
	})

	tab:CreateButton({ Name = "Re-scan All", Callback = function()
		ctx.notify("VulnScan", "Re-scanning " .. tostring(#VULNS) .. " surfaces...")
		local p, f = 0, 0
		for _, vuln in ipairs(VULNS) do
			local ok, result = pcall(vuln.test)
			if ok and result then p += 1 else f += 1 end
		end
		ctx.notify("VulnScan", tostring(p) .. "/" .. tostring(#VULNS) .. " reachable, " .. tostring(f) .. " failed")
	end })
end

function Feature.toggle(state) end

return Feature
