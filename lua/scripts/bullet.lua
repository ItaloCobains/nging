--- Bullet projectile system

local pool = require("scripts.pool")
local event = require("scripts.event")

local bullets = {
  pool = pool.new(200, function()
    return {
      x = 0,
      y = 0,
      dx = 0,
      dy = 0,
      speed = 400,
      color = {r = 255, g = 140, b = 0},
      damage = 1,
      piercing = false,
      active = false,
    }
  end),
}

function bullets.add(x, y, dx, dy, opts)
  opts = opts or {}
  local bullet = bullets.pool:acquire()
  bullet.x = x
  bullet.y = y
  bullet.dx = dx
  bullet.dy = dy
  bullet.speed = opts.speed or 400
  bullet.color = opts.color or {r = 255, g = 140, b = 0}
  bullet.damage = opts.damage or 1
  bullet.piercing = opts.piercing or false
  bullet.active = true
end

function bullets.update(dt)
  local camera = require("scripts.camera")
  bullets.pool:each(function(bullet)
    bullet.x = bullet.x + bullet.dx * bullet.speed * dt
    bullet.y = bullet.y + bullet.dy * bullet.speed * dt

    if bullet.x < -50 or bullet.x > camera.world_w + 50 or bullet.y < -50 or bullet.y > camera.world_h + 50 then
      bullets.pool:release(bullet)
    end
  end)
end

function bullets.draw()
  local camera = require("scripts.camera")
  bullets.pool:each(function(bullet)
    local bx, by = camera.to_screen(bullet.x, bullet.y)
    bx = math.floor(bx)
    by = math.floor(by)
    local adx = math.abs(bullet.dx)
    local ady = math.abs(bullet.dy)

    local glow_offset = 4
    engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 80)

    if adx > 0.65 and ady > 0.65 then
      -- Diagonal: plasma ball (glow square + nucleus in cross)
      engine.draw_rect(bx - glow_offset - 1, by - glow_offset - 1, 14, 14)
      engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 255)
      engine.draw_rect(bx - 1, by + 2, 10, 4)   -- horizontal bar
      engine.draw_rect(bx + 2, by - 1, 4, 10)   -- vertical bar
    elseif adx >= ady then
      -- Horizontal: 14×4
      engine.draw_rect(bx - glow_offset, by - glow_offset, 14 + glow_offset * 2, 4 + glow_offset * 2)
      engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 255)
      engine.draw_rect(bx - 3, by - 2, 14, 4)
    else
      -- Vertical: 4×14
      engine.draw_rect(bx - glow_offset, by - glow_offset, 4 + glow_offset * 2, 14 + glow_offset * 2)
      engine.set_draw_color(bullet.color.r, bullet.color.g, bullet.color.b, 255)
      engine.draw_rect(bx - 2, by - 3, 4, 14)
    end
  end)
end

function bullets.get_all()
  local result = {}
  bullets.pool:each(function(bullet)
    table.insert(result, bullet)
  end)
  return result
end

function bullets.hit(bullet)
  event.emit("bullet_hit", {x = bullet.x, y = bullet.y})
  if not bullet.piercing then
    bullets.pool:release(bullet)
  end
end

return bullets
