-- bullet.lua
-- Projectile system using object pooling
-- Handles bullet creation, movement, rendering, and collision events

local pool = require("scripts.pool")
local event = require("scripts.event")

local bullets = {
  -- Object pool: reuses 200 bullet slots for efficiency
  -- Pre-allocated at startup to avoid mid-game allocations
  pool = pool.new(200, function()
    return {
      -- Position and movement
      x = 0,                            -- World X position
      y = 0,                            -- World Y position
      dx = 0,                           -- Direction X (-1, 0, 1)
      dy = 0,                           -- Direction Y (-1, 0, 1)
      speed = 400,                      -- Pixels per second

      -- Appearance
      color = {r = 255, g = 140, b = 0},  -- Orange color (RGB)

      -- Game mechanics
      damage = 1,                       -- Damage to enemies
      piercing = false,                 -- Ignore first hit?
      active = false,                   -- In use?
    }
  end),
}

-- Spawn a new bullet
-- Gets a bullet from the pool and initializes it with given parameters
-- @param x (number) - Starting world X position
-- @param y (number) - Starting world Y position
-- @param dx (number) - Direction X (normalized: -1, 0, or 1)
-- @param dy (number) - Direction Y (normalized: -1, 0, or 1)
-- @param opts (table) - Optional parameters:
--   - speed (number) - Pixels per second (default 400)
--   - color (table) - {r, g, b} color (default orange)
--   - damage (number) - Damage to enemies (default 1)
--   - piercing (bool) - Ignore first hit (default false)
-- @usage: bullets.add(100, 100, 1, 0, {damage=99, piercing=true})
function bullets.add(x, y, dx, dy, opts)
  opts = opts or {}

  -- Acquire bullet from pool (reuse or create new)
  local bullet = bullets.pool:acquire()

  -- Initialize position and direction
  bullet.x = x
  bullet.y = y
  bullet.dx = dx
  bullet.dy = dy

  -- Set bullet properties from options
  bullet.speed = opts.speed or 400
  bullet.color = opts.color or {r = 255, g = 140, b = 0}
  bullet.damage = opts.damage or 1
  bullet.piercing = opts.piercing or false
  bullet.active = true  -- Mark as active in pool
end

-- Update all active bullets
-- Moves bullets and despawns those that leave the world
-- @param dt (number) - Delta time in seconds
-- @usage: bullets.update(0.016)
function bullets.update(dt)
  local camera = require("scripts.camera")

  -- Update each active bullet
  bullets.pool:each(function(bullet)
    -- Move bullet based on direction and speed
    bullet.x = bullet.x + bullet.dx * bullet.speed * dt
    bullet.y = bullet.y + bullet.dy * bullet.speed * dt

    -- Despawn if bullet leaves world (with 50px margin for smooth exit)
    if bullet.x < -50 or bullet.x > camera.world_w + 50 or
       bullet.y < -50 or bullet.y > camera.world_h + 50 then
      bullets.pool:release(bullet)  -- Return to pool for reuse
    end
  end)
end

-- Render all active bullets
-- Draws directional bullets with glow effect
-- Shape changes based on direction (horizontal/vertical/diagonal)
-- @usage: bullets.draw()
function bullets.draw()
  local camera = require("scripts.camera")

  bullets.pool:each(function(bullet)
    -- Convert world coordinates to screen coordinates
    local bx, by = camera.to_screen(bullet.x, bullet.y)
    bx = math.floor(bx)
    by = math.floor(by)

    -- Determine if bullet is primarily horizontal or vertical
    local adx = math.abs(bullet.dx)
    local ady = math.abs(bullet.dy)

    local glow_offset = 4
    -- Draw glow halo (semi-transparent)
    engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 80)

    if adx > 0.65 and ady > 0.65 then
      -- DIAGONAL: plasma ball (cross pattern)
      engine.draw_rect(bx - glow_offset - 1, by - glow_offset - 1, 14, 14)
      engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 255)
      engine.draw_rect(bx - 1, by + 2, 10, 4)   -- Horizontal bar
      engine.draw_rect(bx + 2, by - 1, 4, 10)   -- Vertical bar

    elseif adx >= ady then
      -- HORIZONTAL: elongated left-right (14×4)
      engine.draw_rect(bx - glow_offset, by - glow_offset, 14 + glow_offset * 2, 4 + glow_offset * 2)
      engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 255)
      engine.draw_rect(bx - 3, by - 2, 14, 4)

    else
      -- VERTICAL: elongated up-down (4×14)
      engine.draw_rect(bx - glow_offset, by - glow_offset, 4 + glow_offset * 2, 14 + glow_offset * 2)
      engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 255)
      engine.draw_rect(bx - 2, by - 3, 4, 14)
    end
  end)
end

-- Get list of all active bullets
-- Used for collision detection
-- @return (table) - Array of active bullet objects
-- @usage: local all_bullets = bullets.get_all()
function bullets.get_all()
  local result = {}
  bullets.pool:each(function(bullet)
    table.insert(result, bullet)
  end)
  return result
end

-- Handle bullet hitting an enemy
-- Emits event for particles/sound and releases bullet (unless piercing)
-- @param bullet (object) - The bullet that hit
-- @usage: bullets.hit(bullet)
function bullets.hit(bullet)
  -- Emit hit event (triggers particles and sound)
  event.emit("bullet_hit", {x = bullet.x, y = bullet.y})

  -- Release bullet unless it pierces through
  if not bullet.piercing then
    bullets.pool:release(bullet)  -- Return to pool for reuse
  end
end

return bullets
