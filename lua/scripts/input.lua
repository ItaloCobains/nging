-- Input state management with prev/curr tracking

local input = {
  prev = {},
  curr = {},
}

local tracked_keys = {
  engine.keys.W,
  engine.keys.A,
  engine.keys.S,
  engine.keys.D,
  engine.keys.UP,
  engine.keys.DOWN,
  engine.keys.LEFT,
  engine.keys.RIGHT,
  engine.keys.SPACE,
}

function input.update()
  for i, key in ipairs(tracked_keys) do
    input.prev[key] = input.curr[key]
    input.curr[key] = engine.is_key_down(key)
  end
end

function input.just_pressed(key)
  return input.curr[key] and not input.prev[key]
end

function input.is_down(key)
  return input.curr[key] == true
end

return input
