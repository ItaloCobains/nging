-- particle.lua
-- Particle effects system for visual feedback
-- Used for death bursts and impact sparks with alpha fade-out

local pool = require("scripts.pool")

local particle = {}

-- Particle pool: 256 particles for efficient reuse
local particle_pool = pool.new(256, function()
  return {
    -- Position and movement
    x = 0,          -- World X position
    y = 0,          -- World Y position
    vx = 0,         -- Velocity X (px/s)
    vy = 0,         -- Velocity Y (px/s)

    -- Lifetime and rendering
    life = 0,       -- Remaining lifetime (seconds)
    max_life = 0,   -- Original lifetime (for alpha calculation)
    r = 255,        -- Red component
    g = 255,        -- Green component
    b = 255,        -- Blue component
    size = 1,       -- Pixel size

    active = false,
  }
end)

-- Emit a burst of particles at a location
-- Creates particles with random velocity and fade-out effect
-- @param x (number) - Center X position
-- @param y (number) - Center Y position
-- @param opts (table) - Optional parameters:
--   - count (number) - Number of particles (default 5)
--   - speed_min (number) - Min velocity (default 50 px/s)
--   - speed_max (number) - Max velocity (default 150 px/s)
--   - color (table) - {r, g, b} color (default white)
--   - lifetime (number) - Fade duration (default 0.4s)
--   - size (number) - Pixel size (default 2)
-- @usage: particle.emit(100, 100, {count=12, color={255,0,0}, lifetime=0.5})
function particle.emit(x, y, opts)
  opts = opts or {}

  local count = opts.count or 5
  local speed_min = opts.speed_min or 50
  local speed_max = opts.speed_max or 150
  local color = opts.color or {255, 255, 255}
  local lifetime = opts.lifetime or 0.4
  local size = opts.size or 2

  -- Spawn requested number of particles
  for i = 1, count do
    local p = particle_pool:acquire()

    -- Set position
    p.x = x
    p.y = y

    -- Random velocity (all directions equally)
    local angle = (math.random() * 2 - 1) * math.pi  -- -π to +π
    local speed = speed_min + math.random() * (speed_max - speed_min)
    p.vx = math.cos(angle) * speed
    p.vy = math.sin(angle) * speed

    -- Lifetime and appearance
    p.life = lifetime
    p.max_life = lifetime
    p.r = color[1] or 255
    p.g = color[2] or 255
    p.b = color[3] or 255
    p.size = size

    p.active = true  -- Mark as active in pool
  end
end

-- Update all active particles
-- Moves particles and removes those that have expired
-- @param dt (number) - Delta time in seconds
-- @usage: particle.update(0.016)
function particle.update(dt)
  particle_pool:each(function(p)
    -- Update position based on velocity
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt

    -- Decrement lifetime
    p.life = p.life - dt

    -- Remove particle when lifetime expires
    if p.life <= 0 then
      p.active = false
    end
  end)
end

-- Render all active particles
-- Alpha fades from opaque to transparent based on remaining lifetime
-- @usage: particle.draw()
function particle.draw()
  particle_pool:each(function(p)
    -- Calculate alpha: full opacity when just born, transparent when dying
    -- Ratio: 1.0 = fresh, 0.0 = expired
    local ratio = p.life / p.max_life
    -- Alpha 0-255 based on remaining lifetime
    engine.set_draw_color(p.r, p.g, p.b, math.floor(255 * ratio))
    -- Draw small square
    engine.draw_rect(math.floor(p.x), math.floor(p.y), p.size, p.size)
  end)
end

-- Clear all particles
-- Called when restarting game or clearing game state
-- @usage: particle.clear()
function particle.clear()
  particle_pool:clear()
end

return particle
