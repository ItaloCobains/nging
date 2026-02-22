-- enemy.lua
-- Enemy AI system with multiple enemy types and behaviors
-- Uses object pooling for 100 enemies, progressive difficulty scaling

local pool = require("scripts.pool")
local event = require("scripts.event")

local enemies = {
  -- Object pool: reuses 100 enemy slots
  pool = pool.new(100, function()
    return {
      -- Position and size
      x = 0,                             -- World X position
      y = 0,                             -- World Y position
      w = 22,                            -- Collision box width
      h = 22,                            -- Collision box height

      -- Health and damage
      hp = 1,                            -- Current hit points
      points = 1,                        -- Score awarded on death

      -- Movement
      speed = 80,                        -- Pixels per second
      dir_x = 0,                         -- Facing direction X
      dir_y = 0,                         -- Facing direction Y

      -- Appearance
      color = {r = 220, g = 60, b = 60},  -- RGB color

      -- AI and type
      type_name = "basic",               -- Enemy type: basic/scout/tank/zigzagger
      anim_timer = 0,                    -- Animation timer
      zigzag_phase = 0,                  -- Zigzagger oscillation phase

      active = false,                    -- In use?
    }
  end),
}

-- Enemy type definitions
-- Each type has unique stats that affect gameplay difficulty
enemies.types = {
  -- Basic: Simple pursuer, unlocked from wave 1
  basic = {
    hp = 1,                  -- 1 hit to kill
    speed = 80,              -- Slow, predictable
    width = 22,              -- Standard size
    height = 22,
    points = 1,              -- 1 point per kill
    color = { r = 220, g = 60, b = 60 },  -- Red
  },

  -- Scout: Fast pursuer, unlocked at score 10
  scout = {
    hp = 1,
    speed = 150,             -- 1.875x faster than basic
    width = 16,              -- Smaller (easier to hit)
    height = 16,
    points = 2,              -- Double points
    color = { r = 255, g = 165, b = 0 },  -- Orange
  },

  -- Tank: Slow tanky enemy, unlocked at score 25
  tank = {
    hp = 3,                  -- 3 hits to kill
    speed = 50,              -- Slowest type
    width = 30,              -- Largest (harder to dodge)
    height = 30,
    points = 5,              -- High reward
    color = { r = 150, g = 50, b = 200 },  -- Purple
  },

  -- Zigzagger: Erratic movement, unlocked at score 50
  zigzagger = {
    hp = 1,
    speed = 120,
    width = 18,
    height = 18,
    points = 3,              -- Balanced reward
    color = { r = 50, g = 200, b = 100 },  -- Green
  },
}

-- Spawn an enemy at a location
-- Initializes enemy with type stats and animation
-- @param x (number) - Spawn X position
-- @param y (number) - Spawn Y position
-- @param type_name (string) - Enemy type: "basic", "scout", "tank", "zigzagger"
-- @usage: enemies.spawn(100, 100, "scout")
function enemies.spawn(x, y, type_name)
  type_name = type_name or "basic"
  local type_def = enemies.types[type_name]

  -- Acquire enemy from pool
  local enemy = enemies.pool:acquire()

  -- Set position
  enemy.x = x
  enemy.y = y

  -- Copy type stats
  enemy.hp = type_def.hp
  enemy.speed = type_def.speed
  enemy.w = type_def.width
  enemy.h = type_def.height
  enemy.points = type_def.points
  enemy.color = type_def.color
  enemy.type_name = type_name

  -- Initialize animation state
  enemy.anim_timer = math.random() * math.pi * 2  -- Random animation phase
  enemy.dir_x = 0
  enemy.dir_y = 0
  enemy.zigzag_phase = 0

  enemy.active = true  -- Mark as active in pool
end

-- Update all active enemies
-- Handles AI (pursuit), animation, and death detection
-- @param dt (number) - Delta time in seconds
-- @param px (number) - Player X position (pursuit target)
-- @param py (number) - Player Y position (pursuit target)
-- @usage: enemies.update(0.016, player.x, player.y)
function enemies.update(dt, px, py)
  enemies.pool:each(function(enemy)
    -- Calculate direction to player
    local dx = px - enemy.x
    local dy = py - enemy.y
    local len = math.sqrt(dx * dx + dy * dy)

    -- Normalize direction (make length = 1)
    local dx_norm = 0
    local dy_norm = 0
    if len > 0 then
      dx_norm = dx / len
      dy_norm = dy / len
    end

    -- Move toward player at enemy's speed
    enemy.x = enemy.x + dx_norm * enemy.speed * dt
    enemy.y = enemy.y + dy_norm * enemy.speed * dt

    -- Special behavior for zigzagger: oscillate perpendicular to target
    if enemy.type_name == "zigzagger" and len > 0 then
      -- Calculate perpendicular direction (rotated 90 degrees)
      local perp_x = -dy_norm
      local perp_y = dx_norm
      -- Oscillate with sine wave (left-right wiggle)
      enemy.zigzag_phase = enemy.zigzag_phase + 3.0 * dt
      enemy.x = enemy.x + perp_x * math.sin(enemy.zigzag_phase) * 60 * dt
      enemy.y = enemy.y + perp_y * math.sin(enemy.zigzag_phase) * 60 * dt
    end

    -- Store facing direction for animation/rendering
    enemy.dir_x = dx_norm
    enemy.dir_y = dy_norm
    enemy.anim_timer = enemy.anim_timer + dt  -- Update animation timer

    -- Check if enemy is dead
    if enemy.hp <= 0 then
      -- Emit death event (triggers score, particles, etc.)
      event.emit("enemy_died", {
        x = enemy.x,
        y = enemy.y,
        type = enemy.type_name,
        points = enemy.points,
        color = enemy.color
      })
      -- Return enemy to pool for reuse
      enemies.pool:release(enemy)
    end
  end)
end

function enemies.draw()
  local camera = require("scripts.camera")
  enemies.pool:each(function(enemy)
    if not camera.is_visible(enemy.x, enemy.y, enemy.w, enemy.h) then
      return
    end

    local ex, ey = camera.to_screen(enemy.x, enemy.y)
    ex = math.floor(ex)
    ey = math.floor(ey)

    local t = enemy.anim_timer
    local bob = math.floor(math.sin(t * 4) * 1.5)
    local ant_sway = math.floor(math.sin(t * 5) * 2)
    local eye_size = 4 + (math.floor(math.abs(math.sin(t * 3))) > 0.5 and 1 or 0)

    local ey_anim = ey + bob
    local col = enemy.color

    if enemy.type_name == "basic" or enemy.type_name == "scout" then
      -- Left antenna (sways right)
      engine.set_draw_color(col.r, col.g, col.b, 255)
      engine.draw_rect(ex + 4 + ant_sway, ey_anim - 5, 3, 6)

      -- Right antenna (sways left)
      engine.set_draw_color(col.r, col.g, col.b, 255)
      engine.draw_rect(ex + 15 - ant_sway, ey_anim - 5, 3, 6)

      -- Head
      engine.set_draw_color(col.r, col.g, col.b, 255)
      engine.draw_rect(ex + 5, ey_anim + 0, 12, 8)

      -- Left eye (with pulse)
      engine.set_draw_color(255, 220, 50, 255)
      engine.draw_rect(ex + 5, ey_anim + 2, eye_size, eye_size)

      -- Right eye (with pulse)
      engine.set_draw_color(255, 220, 50, 255)
      engine.draw_rect(ex + 13, ey_anim + 2, eye_size, eye_size)

      -- Body
      engine.set_draw_color(col.r, col.g, col.b, 255)
      engine.draw_rect(ex + 2, ey_anim + 6, 18, 12)

    elseif enemy.type_name == "tank" then
      -- Tank: simple filled square
      engine.set_draw_color(col.r, col.g, col.b, 255)
      engine.draw_rect(ex + 2, ey + 2, enemy.w - 4, enemy.h - 4)
      engine.set_draw_color(col.r + 40, col.g + 40, col.b, 255)
      engine.draw_rect_outline(ex, ey, enemy.w, enemy.h)

      -- HP bar above tank
      engine.set_draw_color(100, 50, 50, 255)
      engine.draw_rect(ex + 0, ey - 8, 30, 4)
      local hp_ratio = enemy.hp / 3
      engine.set_draw_color(0, 255, 0, 255)
      engine.draw_rect(ex + 0, ey - 8, math.floor(30 * hp_ratio), 4)

    elseif enemy.type_name == "zigzagger" then
      -- Zigzagger: diamond shape
      engine.set_draw_color(col.r, col.g, col.b, 255)
      local half_w = enemy.w / 2
      local half_h = enemy.h / 2
      engine.draw_rect(ex + half_w - 3, ey - half_h + 2, 6, half_h - 2)
      engine.draw_rect(ex - half_w + 2, ey + 2, half_w - 2, half_h - 4)
      engine.draw_rect(ex + half_w, ey + 2, half_w - 2, half_h - 4)
    end
  end)
end

function enemies.get_all()
  local result = {}
  enemies.pool:each(function(enemy)
    table.insert(result, enemy)
  end)
  return result
end

function enemies.clear()
  enemies.pool:clear()
end

return enemies
