-- event.lua
-- Pub/Sub event system for decoupled game communication
-- Allows modules to communicate without direct dependencies

local event = {}
local listeners = {}  -- Table of event_name -> {fn1, fn2, ...}

-- Register a listener for an event
-- @param name (string) - Event name (e.g., "enemy_died")
-- @param fn (function) - Callback function(data)
-- @usage: event.on("enemy_died", function(e) print(e.x, e.y) end)
function event.on(name, fn)
  if not listeners[name] then
    listeners[name] = {}  -- Create listener list if first time
  end
  table.insert(listeners[name], fn)
end

-- Emit an event to all registered listeners
-- @param name (string) - Event name
-- @param data (table) - Data to pass to listeners
-- @usage: event.emit("enemy_died", {x=100, y=200, points=5})
function event.emit(name, data)
  if listeners[name] then
    for _, fn in ipairs(listeners[name]) do
      fn(data)  -- Call each listener with the data
    end
  end
end

-- Clear all registered listeners (typically called when game restarts)
-- @usage: event.clear()
function event.clear()
  listeners = {}
end

return event
