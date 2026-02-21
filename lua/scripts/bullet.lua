--- Bullet projectile system

local bullets = {
  list = {},
  speed = 400,
  width = 8,
  height = 8,
}

function bullets.add(x, y, dx, dy)
  table.insert(bullets.list, {
    x = x,
    y = y,
    dx = dx,
    dy = dy,
  })
end

function bullets.update(dt)
  local i = 1
  while i <= #bullets.list do
    local bullet = bullets.list[i]
    bullet.x = bullet.x + bullet.dx * bullets.speed * dt
    bullet.y = bullet.y + bullet.dy * bullets.speed * dt

    if bullet.x < 0 or bullet.x > 800 or bullet.y < 0 or bullet.y > 600 then
      table.remove(bullets.list, i)
    else
      i = i + 1
    end
  end
end

function bullets.draw()
  for _, bullet in ipairs(bullets.list) do
    local bx = math.floor(bullet.x)
    local by = math.floor(bullet.y)

    local w, h
    if math.abs(bullet.dx) >= math.abs(bullet.dy) then
      w, h = 14, 4
    else
      w, h = 4, 14
    end

    local glow_offset = 4
    engine.set_draw_color(255, 140, 0, 80)
    engine.draw_rect(bx - glow_offset, by - glow_offset, w + glow_offset * 2, h + glow_offset * 2)

    engine.set_draw_color(255, 180, 0, 255)
    engine.draw_rect(bx - (w - bullets.width) / 2, by - (h - bullets.height) / 2, w, h)
  end
end

return bullets
