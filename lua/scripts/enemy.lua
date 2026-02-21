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
  engine.set_draw_color(220, 50, 50, 255)
  for _, enemy in ipairs(enemies.list) do
    engine.draw_rect(math.floor(enemy.x), math.floor(enemy.y), enemies.width, enemies.height)
  end
end

return enemies
