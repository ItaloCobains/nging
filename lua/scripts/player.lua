--- Player character controller

local player = {
  x = 400,
  y = 300,
  width = 24,
  height = 24,
  vx = 0,
  vy = 0,
  speed = 200,
  hp = 3,
}

function player.update(dt)
  player.vx = 0
  player.vy = 0

  if engine.is_key_down(engine.keys.W) then
    player.vy = -player.speed
  end
  if engine.is_key_down(engine.keys.S) then
    player.vy = player.speed
  end
  if engine.is_key_down(engine.keys.A) then
    player.vx = -player.speed
  end
  if engine.is_key_down(engine.keys.D) then
    player.vx = player.speed
  end

  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt

  player.check_shoot(dt)
end

function player.check_shoot(dt)
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

  if dx ~= 0 or dy ~= 0 then
    local len = math.sqrt(dx * dx + dy * dy)
    dx = dx / len
    dy = dy / len

    local bullets = require("scripts.bullet")
    bullets.add(player.x + player.width / 2, player.y + player.height / 2, dx, dy)
  end
end

function player.draw()
  engine.set_draw_color(255, 255, 255, 255)
  engine.draw_rect(math.floor(player.x), math.floor(player.y), player.width, player.height)
end

function player.take_damage()
  player.hp = player.hp - 1
end

return player
