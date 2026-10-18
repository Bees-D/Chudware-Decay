--[[ ui/window.luau — Rayfield window + tab layout. ]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Chudware",
	LoadingTitle = "Chudware — Decay",
	LoadingSubtitle = "Decay (97393041934796)",
	ConfigurationSaving = { Enabled = true, FolderName = "Chudware", FileName = "Decay" },
	KeySystem = false,
})

local Tabs = {
	Visuals  = Window:CreateTab("Visuals",  4483362458),
	Combat   = Window:CreateTab("Combat",   4483362458),
	Movement = Window:CreateTab("Movement", 4483362458),
	Misc     = Window:CreateTab("Misc",     4483362458),
}

return { Window = Window, Tabs = Tabs, Rayfield = Rayfield }
