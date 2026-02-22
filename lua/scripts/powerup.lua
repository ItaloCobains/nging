-- powerup.lua
-- Power-up system with spawning, collection, and effects
-- 15% chance to drop from enemies, picked up automatically on collision

local powerup = {}

-- Power-up type definitions
-- Each type has a color and an effect function
powerup.types = {
  -- Health: Restore 1 HP (max 3)
  health = {
    color = {255, 80, 80},   -- Red
    effect = function(player)
      if player.hp < 3 then
        player.hp = player.hp + 1
      end
    end,
  },

  -- Rapid Fire: Double fire rate for 5 seconds
  rapid = {
    color = {255, 220, 0},   -- Yellow
    effect = function(player)
      player.rapid_timer = 5.0  -- Duration in seconds
      -- Cut shooting interval in half (double fire rate)
      player.shoot_interval = player.base_shoot_interval / 2
    end,
  },

  -- Shield: Absorb 1 hit
  shield = {
    color = {100, 200, 255}, -- Blue
    effect = function(player)
      player.shielded = true  -- Absorbs next damage
    end,
  },
}

-- List of active power-ups in the world
powerup.list = {}

-- Attempt to drop a power-up at a location
-- 15% chance to spawn a random power-up type
-- @param x (number) - Drop X position
-- @param y (number) - Drop Y position
-- @usage: powerup.try_drop(enemy.x, enemy.y)
function powerup.try_drop(x, y)
  if math.random() < 0.15 then  -- 15% chance
    local types = {"health", "rapid", "shield"}
    local typ = types[math.random(1, #types)]
    table.insert(powerup.list, {
      x = x,
      y = y,
      type = typ,
      w = 14,  -- Collision box width
      h = 14,  -- Collision box height
    })
  end
end

-- Update power-ups
-- Check for player collision and apply effects
-- @param dt (number) - Delta time in seconds
-- @param player (table) - Player object
-- @usage: powerup.update(0.016, player)
function powerup.update(dt, player)
  local to_remove = {}

  for i, pu in ipairs(powerup.list) do
    -- Calculate distance from player to power-up
    local dx = pu.x - player.x
    local dy = pu.y - player.y
    local dist = math.sqrt(dx * dx + dy * dy)

    -- Pickup if close to player (collision radius ~20px)
    if dist < 20 then
      -- Apply power-up effect
      powerup.types[pu.type].effect(player)
      -- Mark for removal
      table.insert(to_remove, i)
    end
  end

  -- Remove picked-up power-ups (in reverse order to avoid index issues)
  for i = #to_remove, 1, -1 do
    table.remove(powerup.list, to_remove[i])
  end
end

-- Render all active power-ups
-- Shows colored square with first letter of type
-- @usage: powerup.draw()
function powerup.draw()
  for _, pu in ipairs(powerup.list) do
    local typ = powerup.types[pu.type]

    -- Draw colored square (14×14)
    engine.set_draw_color(typ.color[1], typ.color[2], typ.color[3], 255)
    engine.draw_rect(math.floor(pu.x - 7), math.floor(pu.y - 7), 14, 14)

    -- Draw first letter (H, R, or S)
    local letter = string.sub(pu.type, 1, 1):upper()
    engine.set_draw_color(0, 0, 0, 255)  -- Black text
    engine.draw_text(letter, math.floor(pu.x - 3), math.floor(pu.y - 5))
  end
end

-- Clear all power-ups
-- Called when restarting game
-- @usage: powerup.clear()
function powerup.clear()
  powerup.list = {}
end

return powerup
