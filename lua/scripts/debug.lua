-- debug.lua
-- Debug overlay for development information display
-- Toggled with F key

local debug = {}

-- Debug visibility state
debug.visible = false -- F toggles this

-- Render debug information
-- Shows development info when visible (F enabled)
-- Positioned in bottom-right corner of screen
-- @param game_state (table) - Game object with state variables
-- @usage: debug.draw(game)  -- Called from game.draw() if debug.visible
function debug.draw(game_state)
  if not debug.visible then
    return -- Skip if debug not enabled
  end

  -- Load modules to access game state
  local player = require("scripts.player")

  -- White debug text
  engine.set_draw_color(255, 255, 255, 255)

  -- Bottom-right corner positioning (viewport is 800x600)
  local y_start = 520  -- Near bottom of screen
  local x_pos = 600    -- Right side of screen

  -- Header
  engine.draw_text("DEBUG", x_pos, y_start)

  -- Player position
  engine.draw_text("Player: " .. math.floor(player.x) ..
    "," .. math.floor(player.y), x_pos, y_start + 20)

  -- Player health
  engine.draw_text("HP: " .. player.hp, x_pos, y_start + 40)

  -- Wave progress
  engine.draw_text("Wave: " .. game_state.wave, x_pos, y_start + 60)

  -- Enemies remaining to kill
  engine.draw_text("Enemies left: " .. game_state.wave_enemies_left, x_pos, y_start + 80)
end

return debug
