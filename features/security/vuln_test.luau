local Feature = {}
Feature.name = "Exploit Lab"
Feature.group = "Security"

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function resolve(path)
	local node = RS
	for seg in string.gmatch(path, "[^%.]+") do
		if not node then return nil end
		local ok, child = pcall(function() return node:FindFirstChild(seg) or node:WaitForChild(seg, 3) end)
		node = ok and child or nil
	end
	return node
end

local function tryFire(remote, ...)
	if not remote then return false, "Remote not found" end
	local ok, err = pcall(function(...) remote:FireServer(...) end, ...)
	if ok then return true, "Fired OK" end
	return false, tostring(err)
end

local function tryInvoke(remote, ...)
	if not remote then return false, "RemoteFunction not found" end
	local ok, result = pcall(function(...) return remote:InvokeServer(...) end, ...)
	if ok then return true, tostring(result) end
	return false, tostring(result)
end

local CATEGORIES = {
	{
		name = "Item Duplication",
		tests = {
			{ name = "Admin.GiveItem (give self items)", run = function()
				local r = resolve("Admin.GiveItem")
				if not r then return false, "Admin.GiveItem not found" end
				local ok, err = tryFire(r, LP.Name, "Wood", 100)
				if ok then return true, "Fired GiveItem(Wood x100) - check inventory" end
				return false, err
			end },
			{ name = "DropSlot (dupe via drop)", run = function()
				local r = resolve("Inventory.RemoteEvents.DropSlot")
				return tryFire(r, 1)
			end },
			{ name = "DropItem (loot dupe)", run = function()
				local r = resolve("LootSystem.RemoteEvents.DropItem")
				return tryFire(r, 1)
			end },
			{ name = "ReskinItem (item transform)", run = function()
				local r = resolve("Deployables.RemoteEvents.ReskinItem")
				return tryFire(r, "Wood Wall", "Stone Wall")
			end },
			{ name = "BuyFromVendor (free buy)", run = function()
				local r = resolve("Players.BuyFromVendor")
				return tryFire(r, "Rifle", 1)
			end },
			{ name = "BuyKit (free kit)", run = function()
				local r = resolve("Kits.BuyKit")
				return tryFire(r, "StarterKit")
			end },
		}
	},
	{
		name = "Building Exploits",
		tests = {
			{ name = "UpgradeToHQM (free upgrade)", run = function()
				local r = resolve("BuildingSystem.RemoteEvents.UpgradeToHighQualityMetal")
				return tryFire(r)
			end },
			{ name = "UpgradeToMetal", run = function()
				local r = resolve("BuildingSystem.RemoteEvents.UpgradeToMetal")
				return tryFire(r)
			end },
			{ name = "UpgradeToStone", run = function()
				local r = resolve("BuildingSystem.RemoteEvents.UpgradeToStone")
				return tryFire(r)
			end },
			{ name = "UpgradeToWood", run = function()
				local r = resolve("BuildingSystem.RemoteEvents.UpgradeToWood")
				return tryFire(r)
			end },
		}
	},
	{
		name = "Spawn & Respawn",
		tests = {
			{ name = "Respawn (instant respawn)", run = function()
				local r = resolve("DeathScreen.Respawn")
				return tryFire(r)
			end },
			{ name = "OilrigRespawn", run = function()
				local r = resolve("LootSystem.RemoteEvents.OilrigRespawn")
				return tryFire(r)
			end },
			{ name = "AddCharacter (extra char)", run = function()
				local r = resolve("Teams.RemoteEvents.AddCharacter")
				return tryFire(r, LP.Name)
			end },
			{ name = "SpawnSpark (force resource)", run = function()
				local r = resolve("Resources.RemoteEvents.SpawnSpark")
				return tryFire(r)
			end },
			{ name = "SupplyDropNotification (fake drop)", run = function()
				local r = resolve("SupplyDrops.SupplyDropNotification")
				return tryFire(r, Vector3.new(0, 100, 0))
			end },
		}
	},
	{
		name = "RemoteFunctions (data leak)",
		tests = {
			{ name = "DecaySettingsRemote", run = function()
				local r = resolve("DecaySettingsRemote")
				return tryInvoke(r)
			end },
			{ name = "CalculateCFrame", run = function()
				local r = resolve("Deployables.RemoteEvents.CalculateCFrame")
				if r and r:IsA("RemoteFunction") then return tryInvoke(r) end
				return false, "Not a RemoteFunction"
			end },
			{ name = "CanOpenLock", run = function()
				local r = resolve("Deployables.RemoteEvents.CanOpenLock")
				if r and r:IsA("RemoteFunction") then return tryInvoke(r, "0000") end
				return false, "Not a RemoteFunction"
			end },
			{ name = "GetModdedDataClient", run = function()
				local r = resolve("ItemData.GetModdedDataClient")
				if r and r:IsA("RemoteFunction") then return tryInvoke(r) end
				return false, "Not a RemoteFunction"
			end },
			{ name = "GetGeneratedMapImage", run = function()
				local r = resolve("MapGeneration.GetGeneratedMapImage")
				if r and r:IsA("RemoteFunction") then return tryInvoke(r) end
				return false, "Not a RemoteFunction"
			end },
			{ name = "Teams.Create", run = function()
				local r = resolve("Teams.RemoteEvents.Create")
				if r and r:IsA("RemoteFunction") then return tryInvoke(r, "TestTeam") end
				return false, "Not a RemoteFunction or not found"
			end },
			{ name = "Teams.Leave", run = function()
				local r = resolve("Teams.RemoteEvents.Leave")
				if r and r:IsA("RemoteFunction") then return tryInvoke(r) end
				return false, "Not a RemoteFunction or not found"
			end },
			{ name = "ToolSystem.GetSides", run = function()
				local r = resolve("ToolSystem.RemoteEvents.GetSides")
				if r and r:IsA("RemoteFunction") then return tryInvoke(r) end
				return false, "Not a RemoteFunction or not found"
			end },
		}
	},
	{
		name = "Client-Auth Stats",
		tests = {
			{ name = "WalkSpeed override", run = function()
				local char = LP.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not hum then return false, "No humanoid" end
				local old = hum.WalkSpeed
				hum.WalkSpeed = 50
				local worked = (hum.WalkSpeed == 50)
				hum.WalkSpeed = old
				if worked then return true, "WalkSpeed is client-writable (set 50, reverted)" end
				return false, "Server overrode WalkSpeed"
			end },
			{ name = "JumpPower override", run = function()
				local char = LP.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not hum then return false, "No humanoid" end
				local old = hum.JumpPower
				hum.JumpPower = 100
				local worked = (hum.JumpPower == 100)
				hum.JumpPower = old
				if worked then return true, "JumpPower is client-writable (set 100, reverted)" end
				return false, "Server overrode JumpPower"
			end },
		}
	},
	{
		name = "Info Leaks",
		tests = {
			{ name = "Hardcoded Secret (ClickToMove)", run = function()
				local ok, mod = pcall(function()
					return LP.PlayerScripts:FindFirstChild("PlayerModule")
						and LP.PlayerScripts.PlayerModule:FindFirstChild("ControlModule")
						and LP.PlayerScripts.PlayerModule.ControlModule:FindFirstChild("ClickToMoveController")
				end)
				if ok and mod then return true, "ClickToMoveController accessible (may contain secrets)" end
				return false, "Not accessible"
			end },
			{ name = "LootSettings (predictable RNG)", run = function()
				local r = resolve("LootSettings")
				if r then return true, "LootSettings module accessible" end
				return false, "Not found"
			end },
		}
	},
}

function Feature.init(tab, ctx)
	tab:CreateSection("Exploit Lab")
	tab:CreateParagraph({ Title = "WARNING", Content = "These tests FIRE remotes. Some may affect your game state (items, position, stats). Use at your own risk." })

	local selectedCategory = CATEGORIES[1].name
	local resultParagraph = nil

	local catNames = {}
	for _, cat in ipairs(CATEGORIES) do table.insert(catNames, cat.name) end

	tab:CreateDropdown({
		Name = "Category",
		Options = catNames,
		CurrentOption = { catNames[1] },
		Flag = "vuln_category",
		Callback = function(v)
			if type(v) == "table" then v = v[1] end
			selectedCategory = v
		end
	})

	local function getCategory(name)
		for _, cat in ipairs(CATEGORIES) do
			if cat.name == name then return cat end
		end
		return nil
	end

	tab:CreateButton({ Name = "Run Selected Category", Callback = function()
		local cat = getCategory(selectedCategory)
		if not cat then
			ctx.notify("Exploit Lab", "Category not found: " .. tostring(selectedCategory))
			return
		end

		ctx.notify("Exploit Lab", "Running " .. cat.name .. " (" .. #cat.tests .. " tests)...")
		local passed, failed = 0, 0
		local results = {}

		for _, test in ipairs(cat.tests) do
			local ok, success, detail
			ok, success, detail = pcall(test.run)
			if not ok then
				failed += 1
				table.insert(results, "[FAIL] " .. test.name .. ": " .. tostring(success))
			elseif success then
				passed += 1
				table.insert(results, "[PASS] " .. test.name .. ": " .. tostring(detail))
			else
				failed += 1
				table.insert(results, "[FAIL] " .. test.name .. ": " .. tostring(detail))
			end
		end

		local summary = cat.name .. ": " .. passed .. " passed, " .. failed .. " failed"
		ctx.notify("Exploit Lab", summary)

		for _, line in ipairs(results) do
			warn("[Chudware Exploit] " .. line)
		end
	end })

	tab:CreateButton({ Name = "Run ALL Tests", Callback = function()
		ctx.notify("Exploit Lab", "Running all exploit tests...")
		local totalPass, totalFail = 0, 0
		local allResults = {}

		for _, cat in ipairs(CATEGORIES) do
			for _, test in ipairs(cat.tests) do
				local ok, success, detail
				ok, success, detail = pcall(test.run)
				if not ok then
					totalFail += 1
					table.insert(allResults, "[FAIL] " .. cat.name .. "/" .. test.name .. ": " .. tostring(success))
				elseif success then
					totalPass += 1
					table.insert(allResults, "[PASS] " .. cat.name .. "/" .. test.name .. ": " .. tostring(detail))
				else
					totalFail += 1
					table.insert(allResults, "[FAIL] " .. cat.name .. "/" .. test.name .. ": " .. tostring(detail))
				end
			end
		end

		ctx.notify("Exploit Lab", "Done: " .. totalPass .. " passed, " .. totalFail .. " failed out of " .. (totalPass + totalFail))
		for _, line in ipairs(allResults) do
			warn("[Chudware Exploit] " .. line)
		end
	end })

	tab:CreateSection("Quick Exploits")

	tab:CreateButton({ Name = "Give Self Wood x100", Callback = function()
		local r = resolve("Admin.GiveItem")
		if not r then ctx.notify("Exploit Lab", "Admin.GiveItem not found"); return end
		local ok, err = tryFire(r, LP.Name, "Wood", 100)
		ctx.notify("Exploit Lab", ok and "Fired GiveItem(Wood x100)" or "Failed: " .. tostring(err))
	end })

	tab:CreateButton({ Name = "Give Self Metal x100", Callback = function()
		local r = resolve("Admin.GiveItem")
		if not r then ctx.notify("Exploit Lab", "Admin.GiveItem not found"); return end
		local ok, err = tryFire(r, LP.Name, "Metal Ore", 100)
		ctx.notify("Exploit Lab", ok and "Fired GiveItem(Metal x100)" or "Failed: " .. tostring(err))
	end })

	tab:CreateButton({ Name = "Give Self Sulfur x100", Callback = function()
		local r = resolve("Admin.GiveItem")
		if not r then ctx.notify("Exploit Lab", "Admin.GiveItem not found"); return end
		local ok, err = tryFire(r, LP.Name, "Sulfur Ore", 100)
		ctx.notify("Exploit Lab", ok and "Fired GiveItem(Sulfur x100)" or "Failed: " .. tostring(err))
	end })

	tab:CreateButton({ Name = "Give Self Rifle", Callback = function()
		local r = resolve("Admin.GiveItem")
		if not r then ctx.notify("Exploit Lab", "Admin.GiveItem not found"); return end
		local ok, err = tryFire(r, LP.Name, "Rifle", 1)
		ctx.notify("Exploit Lab", ok and "Fired GiveItem(Rifle x1)" or "Failed: " .. tostring(err))
	end })

	tab:CreateButton({ Name = "Force Respawn", Callback = function()
		local r = resolve("DeathScreen.Respawn")
		if not r then ctx.notify("Exploit Lab", "Respawn remote not found"); return end
		local ok, err = tryFire(r)
		ctx.notify("Exploit Lab", ok and "Respawn fired" or "Failed: " .. tostring(err))
	end })

	tab:CreateButton({ Name = "Leak Decay Settings", Callback = function()
		local r = resolve("DecaySettingsRemote")
		if not r then ctx.notify("Exploit Lab", "DecaySettingsRemote not found"); return end
		local ok, result = tryInvoke(r)
		if ok then
			ctx.notify("Exploit Lab", "Got settings: " .. string.sub(tostring(result), 1, 100))
		else
			ctx.notify("Exploit Lab", "Failed: " .. tostring(result))
		end
	end })

	tab:CreateButton({ Name = "Leak Map Image", Callback = function()
		local r = resolve("MapGeneration.GetGeneratedMapImage")
		if not r or not r:IsA("RemoteFunction") then ctx.notify("Exploit Lab", "GetGeneratedMapImage not found"); return end
		local ok, result = tryInvoke(r)
		if ok then
			ctx.notify("Exploit Lab", "Got map data: " .. string.sub(tostring(result), 1, 100))
		else
			ctx.notify("Exploit Lab", "Failed: " .. tostring(result))
		end
	end })

	tab:CreateSection("Scan Results")

	local scanResults = {}
	local passCount, failCount = 0, 0
	for _, cat in ipairs(CATEGORIES) do
		for _, test in ipairs(cat.tests) do
			table.insert(scanResults, { cat = cat.name, test = test })
		end
	end

	for _, entry in ipairs(scanResults) do
		local ok, success, detail = pcall(entry.test.run)
		local status
		if not ok then
			failCount += 1
			status = "[FAIL] " .. tostring(success)
		elseif success then
			passCount += 1
			status = "[PASS] " .. tostring(detail)
		else
			failCount += 1
			status = "[FAIL] " .. tostring(detail)
		end

		tab:CreateParagraph({
			Title = entry.cat .. " > " .. entry.test.name,
			Content = status
		})
	end

	tab:CreateParagraph({
		Title = "Scan Summary",
		Content = passCount .. "/" .. (passCount + failCount) .. " exploit surfaces reachable. " .. failCount .. " blocked/missing."
	})
end

function Feature.toggle(state) end

return Feature
