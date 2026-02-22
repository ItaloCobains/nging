--- Player character controller

local player = {
  x = 800,
  y = 600,
  width = 24,
  height = 24,
  vx = 0,
  vy = 0,
  speed = 200,
  hp = 3,
  shoot_cooldown = 0,
  anim_timer = 0,
  facing = 1,
  is_moving = false,
  active_weapon = nil,
  shielded = false,
  rapid_timer = 0,
  base_shoot_interval = 0.15,
}

function player.update(dt)
  if player.rapid_timer > 0 then
    player.rapid_timer = player.rapid_timer - dt
    if player.rapid_timer <= 0 then
      player.rapid_timer = 0
      player.active_weapon.shoot_interval = player.base_shoot_interval
    end
  end

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

  local camera = require("scripts.camera")
  player.x = math.max(0, math.min(camera.world_w - player.width, player.x))
  player.y = math.max(0, math.min(camera.world_h - player.height, player.y))

  player.is_moving = (player.vx ~= 0 or player.vy ~= 0)
  if player.vx ~= 0 then
    player.facing = player.vx > 0 and 1 or -1
  end
  if player.is_moving then
    player.anim_timer = player.anim_timer + dt
  end

  player.check_shoot(dt)
end

function player.check_shoot(dt)
  if not player.active_weapon then
    return
  end

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

    local cx = player.x + player.width / 2
    local cy = player.y + player.height / 2
    player.active_weapon.fire(cx, cy, dx, dy)
    player.shoot_cooldown = player.active_weapon.shoot_interval
    engine.play_sound("shoot")
  end
end

function player.draw()
  local camera = require("scripts.camera")
  local px, py = camera.to_screen(player.x, player.y)
  px = math.floor(px)
  py = math.floor(py)

  local walk = math.sin(player.anim_timer * 10)
  local leg_l_y = math.floor(walk * 3)
  local leg_r_y = math.floor(-walk * 3)
  local arm_l_y = math.floor(-walk * 2)
  local arm_r_y = math.floor(walk * 2)

  -- Helmet
  engine.set_draw_color(100, 200, 255, 255)
  engine.draw_rect(px + 5, py + 0, 14, 12)

  -- Visor (adjust for facing direction)
  engine.set_draw_color(30, 30, 80, 255)
  local visor_x = px + 7 - (player.facing < 0 and 2 or 0)
  engine.draw_rect(visor_x, py + 4, 10, 5)

  -- Body
  engine.set_draw_color(50, 120, 200, 255)
  engine.draw_rect(px + 4, py + 12, 16, 10)

  -- Left arm
  engine.set_draw_color(50, 100, 180, 255)
  engine.draw_rect(px + 0, py + 13 + arm_l_y, 5, 10)

  -- Right arm
  engine.set_draw_color(50, 100, 180, 255)
  engine.draw_rect(px + 19, py + 13 + arm_r_y, 5, 10)

  -- Left leg
  engine.set_draw_color(40, 80, 160, 255)
  engine.draw_rect(px + 4, py + 22 + leg_l_y, 6, 10)

  -- Right leg
  engine.set_draw_color(40, 80, 160, 255)
  engine.draw_rect(px + 14, py + 22 + leg_r_y, 6, 10)
end

function player.take_damage()
  if player.shielded then
    player.shielded = false
  else
    player.hp = player.hp - 1
  end
  local event = require("scripts.event")
  event.emit("player_damaged", {x = player.x, y = player.y})
end

function player.reset()
  player.x = 800
  player.y = 600
  player.hp = 3
  player.shoot_cooldown = 0
  player.anim_timer = 0
  player.active_weapon = nil
  player.shielded = false
  player.rapid_timer = 0
end

return player
