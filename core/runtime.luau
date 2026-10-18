--[[ core/runtime.luau — RenderStepped/Heartbeat loop manager + connection registry.
     Features register named per-frame callbacks; a broken callback is caught and dropped,
     never aborting the whole loop (DeepDumper crash rules: isolate + throttle). ]]

local Services = _G._chud_modules and _G._chud_modules.services or require(script.Parent.services)

local Runtime = {}
local renderCbs    = {}   -- [name] = fn(dt)
local heartbeatCbs = {}   -- [name] = fn(dt)
local conns        = {}   -- [name] = RBXScriptConnection

function Runtime.onRender(name, fn) renderCbs[name] = fn end
function Runtime.offRender(name)    renderCbs[name] = nil end
function Runtime.onHeartbeat(name, fn) heartbeatCbs[name] = fn end
function Runtime.offHeartbeat(name)    heartbeatCbs[name] = nil end

-- Track an arbitrary signal connection under a name so it can be dropped on toggle-off.
function Runtime.track(name, connection)
	Runtime.untrack(name)
	conns[name] = connection
end
function Runtime.untrack(name)
	local c = conns[name]
	if c then pcall(function() c:Disconnect() end) end
	conns[name] = nil
end

local started = false
function Runtime.start()
	if started then return end
	started = true
	Services.RunService.RenderStepped:Connect(function(dt)
		for name, fn in pairs(renderCbs) do
			local ok, err = pcall(fn, dt)
			if not ok then
				warn("[Chudware] render '" .. tostring(name) .. "' error: " .. tostring(err))
				renderCbs[name] = nil
			end
		end
	end)
	Services.RunService.Heartbeat:Connect(function(dt)
		for name, fn in pairs(heartbeatCbs) do
			local ok, err = pcall(fn, dt)
			if not ok then
				warn("[Chudware] heartbeat '" .. tostring(name) .. "' error: " .. tostring(err))
				heartbeatCbs[name] = nil
			end
		end
	end)
end

function Runtime.teardown()
	renderCbs, heartbeatCbs = {}, {}
	for name in pairs(conns) do Runtime.untrack(name) end
end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.runtime = Runtime
return Runtime
