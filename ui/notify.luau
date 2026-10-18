--[[ ui/notify.luau — notification wrapper. ]]

local Notify = {}
local rayfield = nil

function Notify.bind(rf) rayfield = rf end

function Notify.send(title, content, duration)
	if not rayfield then return end
	pcall(function()
		rayfield:Notify({ Title = title, Content = content, Duration = duration or 3 })
	end)
end

return Notify
