--- Enemy AI system

local enemies = {
  list = {},
  speed = 80,
  width = 22,
  height = 22,
}

function enemies.spawn(x, y)
  table.insert(enemies.list, {
    x = x,
    y = y,
    hp = 1,
  })
end

function enemies.update(dt, px, py)
  local i = 1
  while i <= #enemies.list do
    local enemy = enemies.list[i]
    local dx = px - enemy.x
    local dy = py - enemy.y
    local len = math.sqrt(dx * dx + dy * dy)

    if len > 0 then
      dx = dx / len
      dy = dy / len
    end

    enemy.x = enemy.x + dx * enemies.speed * dt
    enemy.y = enemy.y + dy * enemies.speed * dt

    if enemy.hp <= 0 then
      table.remove(enemies.list, i)
    else
      i = i + 1
    end
  end
end

function enemies.draw()
  for _, enemy in ipairs(enemies.list) do
    local ex = math.floor(enemy.x)
    local ey = math.floor(enemy.y)

    -- Left antenna
    engine.set_draw_color(200, 40, 40, 255)
    engine.draw_rect(ex + 4, ey - 5, 3, 6)

    -- Right antenna
    engine.set_draw_color(200, 40, 40, 255)
    engine.draw_rect(ex + 15, ey - 5, 3, 6)

    -- Head
    engine.set_draw_color(220, 60, 60, 255)
    engine.draw_rect(ex + 5, ey + 0, 12, 8)

    -- Left eye
    engine.set_draw_color(255, 220, 50, 255)
    engine.draw_rect(ex + 5, ey + 2, 4, 4)

    -- Right eye
    engine.set_draw_color(255, 220, 50, 255)
    engine.draw_rect(ex + 13, ey + 2, 4, 4)

    -- Body
    engine.set_draw_color(200, 40, 40, 255)
    engine.draw_rect(ex + 2, ey + 6, 18, 12)
  end
end

return enemies
