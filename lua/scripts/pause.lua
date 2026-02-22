-- pause.lua
-- Pause system for pausing/resuming game
-- Displays overlay when paused

local pause = {}

-- Pause state
pause.active = false  -- Is game paused?

-- Toggle pause state
-- @usage: pause.toggle()  -- Called from game.update() on ESC key
function pause.toggle()
  pause.active = not pause.active
  engine.play_sound("hit")  -- Feedback sound
end

-- Render pause overlay
-- Only draws if pause is active
-- Called from game.draw() after all game rendering
-- @usage: pause.draw()
function pause.draw()
  if pause.active then
    -- Semi-transparent black overlay
    engine.set_draw_color(0, 0, 0, 180)
    engine.draw_rect(0, 0, 800, 600)  -- Full screen

    -- Pause text
    engine.set_draw_color(255, 255, 255, 255)  -- White
    engine.draw_text("PAUSED", 350, 270)
    engine.draw_text("ESC to resume", 300, 300)
  end
end

return pause
