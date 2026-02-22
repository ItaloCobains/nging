-- input.lua
-- Input state management with edge detection (just_pressed)
-- Tracks previous and current frame states for key press detection

local input = {
  prev = {},  -- Previous frame key states
  curr = {},  -- Current frame key states
}

-- List of keys to track for edge detection (just_pressed)
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
  engine.keys.ESCAPE,  -- Pause toggle
  engine.keys.F,       -- Debug overlay toggle
}

-- Update input state each frame
-- Must be called once per frame before checking input
-- @usage: input.update()
function input.update()
  for i, key in ipairs(tracked_keys) do
    -- Shift current state to previous
    input.prev[key] = input.curr[key]
    -- Read new state from engine
    input.curr[key] = engine.is_key_down(key)
  end
end

-- Check if key was just pressed this frame
-- Returns true only on the frame transition from not-pressed to pressed
-- @param key (number) - Scancode constant (engine.keys.SPACE, etc.)
-- @return (bool) - Was just pressed?
-- @usage: if input.just_pressed(engine.keys.SPACE) then ... end
function input.just_pressed(key)
  return input.curr[key] and not input.prev[key]
end

-- Check if key is currently held down
-- @param key (number) - Scancode constant
-- @return (bool) - Is currently held?
-- @usage: if input.is_down(engine.keys.W) then ... end
function input.is_down(key)
  return input.curr[key] == true
end

return input
