-- debug.lua
-- Debug overlay for development information display
-- Toggled with F key

local debug = {}

-- Debug visibility state
debug.visible = false -- F toggles this

-- Render debug information
-- Shows development info when visible (F enabled)
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

  -- Header
  engine.draw_text("DEBUG", 10, 10)

  -- Player position
  engine.draw_text("Player: " .. math.floor(player.x) ..
    "," .. math.floor(player.y), 10, 30)

  -- Player health
  engine.draw_text("HP: " .. player.hp, 10, 50)

  -- Wave progress
  engine.draw_text("Wave: " .. game_state.wave, 10, 70)

  -- Enemies remaining to kill
  engine.draw_text("Enemies left: " .. game_state.wave_enemies_left, 10, 90)
end

return debug
