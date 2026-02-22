local event = {}
local listeners = {}

function event.on(name, fn)
  if not listeners[name] then
    listeners[name] = {}
  end
  table.insert(listeners[name], fn)
end

function event.emit(name, data)
  if listeners[name] then
    for _, fn in ipairs(listeners[name]) do
      fn(data)
    end
  end
end

function event.clear()
  listeners = {}
end

return event
