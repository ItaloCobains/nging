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
  engine.set_draw_color(255, 255, 50, 255)
  for _, bullet in ipairs(bullets.list) do
    engine.draw_rect(math.floor(bullet.x), math.floor(bullet.y), bullets.width, bullets.height)
  end
end

return bullets
