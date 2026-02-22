local pool = require("scripts.pool")

local particle = {}

local particle_pool = pool.new(256, function()
  return {
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    life = 0,
    max_life = 0,
    r = 255,
    g = 255,
    b = 255,
    size = 1,
    active = false,
  }
end)

function particle.emit(x, y, opts)
  opts = opts or {}
  local count = opts.count or 5
  local speed_min = opts.speed_min or 50
  local speed_max = opts.speed_max or 150
  local color = opts.color or {255, 255, 255}
  local lifetime = opts.lifetime or 0.4
  local size = opts.size or 2

  for i = 1, count do
    local p = particle_pool:acquire()
    p.x = x
    p.y = y
    local angle = (math.random() * 2 - 1) * math.pi
    local speed = speed_min + math.random() * (speed_max - speed_min)
    p.vx = math.cos(angle) * speed
    p.vy = math.sin(angle) * speed
    p.life = lifetime
    p.max_life = lifetime
    p.r = color[1] or 255
    p.g = color[2] or 255
    p.b = color[3] or 255
    p.size = size
    p.active = true
  end
end

function particle.update(dt)
  particle_pool:each(function(p)
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.life = p.life - dt
    if p.life <= 0 then
      p.active = false
    end
  end)
end

function particle.draw()
  particle_pool:each(function(p)
    local ratio = p.life / p.max_life
    engine.set_draw_color(p.r, p.g, p.b, math.floor(255 * ratio))
    engine.draw_rect(math.floor(p.x), math.floor(p.y), p.size, p.size)
  end)
end

function particle.clear()
  particle_pool:clear()
end

return particle
