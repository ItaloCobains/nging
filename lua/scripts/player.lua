-- player.lua
-- Player character controller, health system, and weapon firing
-- Handles movement, collision box, animation, and power-up effects

---Weapon table from scripts.weapons (name, shoot_interval, fire, etc.)
---@class Weapon
---@field name string
---@field shoot_interval number
---@field fire function
local player = {
  -- Position and dimensions
  x = 800,     -- World X position
  y = 600,     -- World Y position
  width = 24,  -- Collision box width
  height = 24, -- Collision box height

  -- Movement
  vx = 0,            -- Current X velocity
  vy = 0,            -- Current Y velocity
  speed = 200,       -- Movement speed (px/s)
  is_moving = false, -- True if moving this frame
  facing = 1,        -- Direction: 1 (right) or -1 (left)

  -- Health and damage
  hp = 3,           -- Current health (1-3)
  shielded = false, -- Shield active (absorb 1 damage)

  -- Shooting
  active_weapon = nil, ---@type Weapon?  Current weapon table
  shoot_cooldown = 0,         -- Remaining cooldown (seconds)
  base_shoot_interval = 0.15, -- Default shoot interval

  -- Power-up effects
  rapid_timer = 0, -- Remaining rapid fire time (seconds)

  -- Animation
  anim_timer = 0, -- Walking animation timer
}

-- Update player state each frame
-- Handles movement input, position updates, clamping, and weapon cooldown
-- @param dt (number) - Delta time in seconds
-- @usage: player.update(0.016)  -- Call once per frame
function player.update(dt)
  -- Update rapid fire power-up timer
  if player.rapid_timer > 0 then
    player.rapid_timer = player.rapid_timer - dt
    if player.rapid_timer <= 0 then
      player.rapid_timer = 0
      -- Restore normal fire rate when rapid expires
      if player.active_weapon then
        player.active_weapon.shoot_interval = player.base_shoot_interval
      end
    end
  end

  -- Reset velocity (not acceleration-based, direct input)
  player.vx = 0
  player.vy = 0

  -- Handle movement input (WASD)
  if engine.is_key_down(engine.keys.W) then
    player.vy = -player.speed -- Up
  end
  if engine.is_key_down(engine.keys.S) then
    player.vy = player.speed -- Down
  end
  if engine.is_key_down(engine.keys.A) then
    player.vx = -player.speed -- Left
  end
  if engine.is_key_down(engine.keys.D) then
    player.vx = player.speed -- Right
  end

  -- Apply velocity to position
  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt

  -- Clamp player to world bounds
  local camera = require("scripts.camera")
  player.x = math.max(0, math.min(camera.world_w - player.width, player.x))
  player.y = math.max(0, math.min(camera.world_h - player.height, player.y))

  -- Update animation and facing direction
  player.is_moving = (player.vx ~= 0 or player.vy ~= 0)
  if player.vx ~= 0 then
    player.facing = player.vx > 0 and 1 or -1
  end
  if player.is_moving then
    player.anim_timer = player.anim_timer + dt -- Animate walking
  end

  -- Check for shooting input and cooldown
  player.check_shoot(dt)
end

-- Check shooting input and fire weapon if cooldown expired
-- Handles arrow key input and weapon firing
-- @param dt (number) - Delta time in seconds
-- @usage: player.check_shoot(0.016)
function player.check_shoot(dt)
  if not player.active_weapon then
    return -- No weapon selected
  end

  -- Decrement cooldown timer
  player.shoot_cooldown = player.shoot_cooldown - dt
  if player.shoot_cooldown < 0 then
    player.shoot_cooldown = 0
  end

  -- Get shoot direction from arrow keys
  local dx, dy = 0, 0

  if engine.is_key_down(engine.keys.UP) then
    dy = -1
  end
  if engine.is_key_down(engine.keys.DOWN) then
    dy = 1
  end
  if engine.is_key_down(engine.keys.LEFT) then
    dx = -1
  end
  if engine.is_key_down(engine.keys.RIGHT) then
    dx = 1
  end

  -- Fire if direction pressed and cooldown expired
  if (dx ~= 0 or dy ~= 0) and player.shoot_cooldown <= 0 then
    -- Normalize direction vector (make length = 1)
    local len = math.sqrt(dx * dx + dy * dy)
    dx = dx / len
    dy = dy / len

    -- Fire from player center
    local cx = player.x + player.width / 2
    local cy = player.y + player.height / 2
    player.active_weapon.fire(cx, cy, dx, dy)

    -- Reset cooldown to weapon's shoot interval
    player.shoot_cooldown = player.active_weapon.shoot_interval
    engine.play_sound("shoot") -- Play gunshot sound
  end
end

function player.draw()
  local camera = require("scripts.camera")
  local px, py = camera.to_screen(player.x, player.y)
  px = math.floor(px)
  py = math.floor(py)

  local walk = math.sin(player.anim_timer * 10)
  local leg_l_y = math.floor(walk * 3)
  local leg_r_y = math.floor(-walk * 3)
  local arm_l_y = math.floor(-walk * 2)
  local arm_r_y = math.floor(walk * 2)

  -- Helmet
  engine.set_draw_color(100, 200, 255, 255)
  engine.draw_rect(px + 5, py + 0, 14, 12)

  -- Visor (adjust for facing direction)
  engine.set_draw_color(30, 30, 80, 255)
  local visor_x = px + 7 - (player.facing < 0 and 2 or 0)
  engine.draw_rect(visor_x, py + 4, 10, 5)

  -- Body
  engine.set_draw_color(50, 120, 200, 255)
  engine.draw_rect(px + 4, py + 12, 16, 10)

  -- Left arm
  engine.set_draw_color(50, 100, 180, 255)
  engine.draw_rect(px + 0, py + 13 + arm_l_y, 5, 10)

  -- Right arm
  engine.set_draw_color(50, 100, 180, 255)
  engine.draw_rect(px + 19, py + 13 + arm_r_y, 5, 10)

  -- Left leg
  engine.set_draw_color(40, 80, 160, 255)
  engine.draw_rect(px + 4, py + 22 + leg_l_y, 6, 10)

  -- Right leg
  engine.set_draw_color(40, 80, 160, 255)
  engine.draw_rect(px + 14, py + 22 + leg_r_y, 6, 10)
end

-- Handle player taking damage
-- Reduces HP or consumes shield if active
-- Emits "player_damaged" event for particle effects and camera shake
-- @usage: player.take_damage()
function player.take_damage()
  if player.shielded then
    -- Shield absorbs damage
    player.shielded = false
  else
    -- Take actual damage
    player.hp = player.hp - 1
  end

  -- Emit event for screen shake, particles, etc.
  local event = require("scripts.event")
  event.emit("player_damaged", { x = player.x, y = player.y })
end

-- Reset player to initial state
-- Called at game start to prepare for new game
-- @usage: player.reset()
function player.reset()
  -- Position (center of world)
  player.x = 800
  player.y = 600

  -- Health
  player.hp = 3
  player.shielded = false

  -- Shooting
  player.shoot_cooldown = 0
  player.active_weapon = nil

  -- Animation
  player.anim_timer = 0

  -- Power-ups
  player.rapid_timer = 0
end

return player
