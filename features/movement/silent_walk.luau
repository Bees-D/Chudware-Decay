local Feature = {}
Feature.name = "Silent Walk"
Feature.group = "Movement"

local enabled = false

function Feature.init(tab, ctx)
	local U = ctx.util
	local Rem = ctx.remotes

	tab:CreateSection("Sound")
	tab:CreateToggle({ Name = "Silent Walk", CurrentValue = false, Flag = "silwalk_toggle", Callback = function(v) Feature.toggle(v) end })

	local function hookSounds()
		if not U.caps.getrawmeta then return end
		local mt = getrawmetatable(game)
		if not mt then return end
		local oldNamecall = mt.__namecall
		local setRO = setreadonly or make_writeable
		if not setRO then return end

		pcall(function()
			setRO(mt, false)
			local soundRemote = Rem.MakeSoundClient()
			mt.__namecall = newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if method == "FireServer" and enabled and soundRemote and self == soundRemote then
					local args = {...}
					if args[1] and type(args[1]) == "string" then
						local lower = string.lower(args[1])
						if string.find(lower, "step") or string.find(lower, "foot") or string.find(lower, "walk") or string.find(lower, "run") or string.find(lower, "land") then
							return nil
						end
					end
				end
				return oldNamecall(self, ...)
			end)
			setRO(mt, true)
		end)
	end

	task.defer(hookSounds)
end

function Feature.toggle(state)
	enabled = state
end

return Feature
