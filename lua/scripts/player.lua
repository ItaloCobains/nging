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
  shoot_cooldown = 0,
  shoot_interval = 0.15,
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
  player.shoot_cooldown = player.shoot_cooldown - dt
  if player.shoot_cooldown < 0 then
    player.shoot_cooldown = 0
  end

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

  if (dx ~= 0 or dy ~= 0) and player.shoot_cooldown <= 0 then
    local len = math.sqrt(dx * dx + dy * dy)
    dx = dx / len
    dy = dy / len

    local bullets = require("scripts.bullet")
    bullets.add(player.x + player.width / 2, player.y + player.height / 2, dx, dy)
    player.shoot_cooldown = player.shoot_interval
  end
end

function player.draw()
  local px = math.floor(player.x)
  local py = math.floor(player.y)

  -- Helmet
  engine.set_draw_color(100, 200, 255, 255)
  engine.draw_rect(px + 5, py + 0, 14, 12)

  -- Visor
  engine.set_draw_color(30, 30, 80, 255)
  engine.draw_rect(px + 7, py + 4, 10, 5)

  -- Body
  engine.set_draw_color(50, 120, 200, 255)
  engine.draw_rect(px + 4, py + 12, 16, 10)

  -- Left arm
  engine.set_draw_color(50, 100, 180, 255)
  engine.draw_rect(px + 0, py + 13, 5, 10)

  -- Right arm
  engine.set_draw_color(50, 100, 180, 255)
  engine.draw_rect(px + 19, py + 13, 5, 10)

  -- Left leg
  engine.set_draw_color(40, 80, 160, 255)
  engine.draw_rect(px + 4, py + 22, 6, 10)

  -- Right leg
  engine.set_draw_color(40, 80, 160, 255)
  engine.draw_rect(px + 14, py + 22, 6, 10)
end

function player.take_damage()
  player.hp = player.hp - 1
end

return player
