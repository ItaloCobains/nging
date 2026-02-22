--- Game state and update/draw callbacks.

local player = require("scripts.player")
local bullets = require("scripts.bullet")
local enemies = require("scripts.enemy")
local camera = require("scripts.camera")
local input = require("scripts.input")
local event = require("scripts.event")
local particle = require("scripts.particle")
local powerup = require("scripts.powerup")
local pause = require("scripts.pause")
local debug = require("scripts.debug")
local scores = require("scripts.scores")
local config = require("scripts.config")

local game = {
  title = "nging",
  version = "0.1.0",
  score = 0,
  game_over = false,
  spawn_timer = 0,
  spawn_interval = 2.0,
  game_timer = 0,
  active_weapon = nil,
  fps = 0,
  wave = 0,
  wave_enemies_to_spawn = 0,
  wave_enemies_left = 0,
  in_wave_break = false,
  wave_break_timer = 0,
}

function game.next_wave()
  game.wave = game.wave + 1
  local count = config.wave_enemy_base + (game.wave - 1) * config.wave_enemy_growth
  game.wave_enemies_to_spawn = count
  game.wave_enemies_left = count
  game.in_wave_break = false
  game.spawn_timer = 0
end

function game.update(dt)
  input.update()
  if dt > 0 then
    game.fps = game.fps * 0.9 + (1 / dt) * 0.1
  end
  game.game_timer = game.game_timer + dt

  if input.just_pressed(engine.keys.ESCAPE) then
    pause.toggle()
  end
  if input.just_pressed(engine.keys.F1) then
    debug.visible = not debug.visible
  end

  if pause.active then
    pause.draw()
    return
  end

  if game.game_over then
    if input.just_pressed(engine.keys.SPACE) then
      game.restart_to_weapon_select()
    end
    return
  end

  player.update(dt)
  bullets.update(dt)
  particle.update(dt)
  enemies.update(dt, player.x + player.width / 2, player.y + player.height / 2)
  powerup.update(dt, player)

  camera.follow(player.x + player.width / 2, player.y + player.height / 2)

  if game.in_wave_break then
    game.wave_break_timer = game.wave_break_timer - dt
    if game.wave_break_timer <= 0 then
      game.next_wave()
    end
  else
    game.spawn_timer = game.spawn_timer + dt
    game.spawn_interval = math.max(0.5, 2.0 - game.score * 0.02)
    if game.wave_enemies_to_spawn > 0 and game.spawn_timer >= game.spawn_interval then
      game.spawn_timer = 0
      game.spawn_enemy()
      game.wave_enemies_to_spawn = game.wave_enemies_to_spawn - 1
    end
  end

  game.check_collisions()
end

function game.spawn_enemy()
  local side = math.random(4)
  local x, y

  if side == 1 then
    x = math.random(0, 1600)
    y = -20
  elseif side == 2 then
    x = math.random(0, 1600)
    y = 1220
  elseif side == 3 then
    x = -20
    y = math.random(0, 1200)
  else
    x = 1620
    y = math.random(0, 1200)
  end

  local enemy_type = "basic"
  if game.score >= 10 and math.random() < 0.3 then
    enemy_type = "scout"
  end
  if game.score >= 25 and math.random() < 0.2 then
    enemy_type = "tank"
  end
  if game.score >= 50 and math.random() < 0.15 then
    enemy_type = "zigzagger"
  end

  enemies.spawn(x, y, enemy_type)
end

function game.check_collisions()
  local BULLET_HITBOX = 8
  local bullet_list = bullets.get_all()
  local enemy_list = enemies.get_all()

  for _, bullet in ipairs(bullet_list) do
    if not bullet.active then goto continue_bullets end
    local hit = false
    for _, enemy in ipairs(enemy_list) do
      if not enemy.active then goto continue_enemies end
      if game.aabb(bullet.x, bullet.y, BULLET_HITBOX, BULLET_HITBOX,
                   enemy.x, enemy.y, enemy.w, enemy.h) then
        enemy.hp = enemy.hp - bullet.damage
        hit = true
      end
      ::continue_enemies::
    end
    if hit then
      bullets.hit(bullet)
    end
    ::continue_bullets::
  end

  for _, enemy in ipairs(enemy_list) do
    if not enemy.active then goto continue_enemy_collision end
    if game.aabb(player.x, player.y, player.width, player.height,
                 enemy.x, enemy.y, enemy.w, enemy.h) then
      player.take_damage()
      enemies.pool:release(enemy)
      if player.hp <= 0 then
        game.game_over = true
      end
    end
    ::continue_enemy_collision::
  end
end

function game.setup_listeners()
  event.clear()

  event.on("enemy_died", function(e)
    game.score = game.score + e.points
    particle.emit(e.x, e.y, {
      count = config.particle_count_death,
      color = {e.color.r, e.color.g, e.color.b},
      lifetime = config.particle_lifetime,
    })
    powerup.try_drop(e.x, e.y)
    camera.shake(config.shake_explosion.amplitude, config.shake_explosion.duration)
    engine.play_sound("explosion")
    game.wave_enemies_left = math.max(0, game.wave_enemies_left - 1)
    if game.wave_enemies_left <= 0 and game.wave_enemies_to_spawn <= 0 and not game.in_wave_break then
      game.in_wave_break = true
      game.wave_break_timer = config.wave_break_duration
      engine.play_sound("wave")
    end
  end)

  event.on("player_damaged", function(e)
    camera.shake(config.shake_damage.amplitude, config.shake_damage.duration)
    engine.play_sound("damage")
  end)

  event.on("bullet_hit", function(e)
    particle.emit(e.x, e.y, {
      count = config.particle_count_hit,
      color = {255, 200, 100},
      lifetime = 0.2,
      size = 2,
    })
    engine.play_sound("hit")
  end)
end

function game.start(weapon_key)
  local weapons = require("scripts.weapons")
  player.active_weapon = weapons[weapon_key]
  player.base_shoot_interval = weapons[weapon_key].shoot_interval
  player.active_weapon.shoot_interval = player.base_shoot_interval
  game.score = 0
  game.game_over = false
  game.spawn_timer = 0
  game.game_timer = 0
  game.in_wave_break = false
  game.wave_break_timer = 0
  pause.active = false

  event.clear()
  particle.clear()
  powerup.clear()
  enemies.clear()
  bullets.pool:clear()

  game.wave = 0
  game.wave_enemies_to_spawn = 0
  game.wave_enemies_left = 0

  game.setup_listeners()
  game.next_wave()
end

function game.restart_to_weapon_select()
  local weapon_select = require("scripts.weapon_select")
  scores.add(game.score)
  engine.play_sound("explosion")
  weapon_select.init()
  engine.update = weapon_select.update
  engine.draw = weapon_select.draw
end

function game.aabb(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
end

function game.draw_corner(cx, cy, flip_x, flip_y)
  engine.set_draw_color(30, 30, 60, 255)
  engine.draw_rect(cx, cy, 60, 60)
  engine.set_draw_color(55, 55, 100, 255)
  engine.draw_rect_outline(cx + 5, cy + 5, 50, 50)
  engine.set_draw_color(80, 80, 140, 255)
  local bx = flip_x and (cx + 35) or (cx + 10)
  engine.draw_rect(bx, cy + 12, 15, 5)
  engine.draw_rect(bx, cy + 22, 22, 4)
end

function game.draw_background()
  local start_tx = math.floor(camera.x / 50)
  local start_ty = math.floor(camera.y / 50)
  local end_tx = start_tx + math.ceil(camera.view_w / 50) + 1
  local end_ty = start_ty + math.ceil(camera.view_h / 50) + 1

  for ty = start_ty, end_ty do
    for tx = start_tx, end_tx do
      if (tx + ty) % 2 == 0 then
        engine.set_draw_color(18, 18, 32, 255)
      else
        engine.set_draw_color(22, 22, 40, 255)
      end
      local sx, sy = camera.to_screen(tx * 50, ty * 50)
      engine.draw_rect(sx, sy, 50, 50)
    end
  end

  engine.set_draw_color(28, 28, 50, 255)
  for x = start_tx * 50, (end_tx + 1) * 50, 50 do
    local sx, sy = camera.to_screen(x, camera.y)
    engine.draw_rect(sx, sy, 1, camera.view_h)
  end
  for y = start_ty * 50, (end_ty + 1) * 50, 50 do
    local sx, sy = camera.to_screen(camera.x, y)
    engine.draw_rect(sx, sy, camera.view_w, 1)
  end

  local p = math.abs(math.sin(game.game_timer * 1.5))
  local br = math.floor(40 + p * 30)
  local bb = math.floor(100 + p * 80)
  engine.set_draw_color(br, 25, bb, 255)
  local border_x, border_y = camera.to_screen(0, 0)
  for i = 0, 3 do
    local bw, bh = camera.to_screen(camera.world_w, camera.world_h)
    bw = math.floor(bw)
    bh = math.floor(bh)
    engine.draw_rect_outline(border_x + i, border_y + i, bw - border_x - i * 2, bh - border_y - i * 2)
  end
end

function game.draw()
  engine.clear(15, 15, 28, 255)
  game.draw_background()

  player.draw()
  bullets.draw()
  enemies.draw()
  particle.draw()
  powerup.draw()

  game.draw_ui()

  if pause.active then
    pause.draw()
  end

  if debug.visible then
    debug.draw(game)
  end
end

function game.draw_ui()
  engine.set_draw_color(255, 255, 255, 255)
  engine.draw_text("HP:", 10, 12)

  for i = 0, 2 do
    if i < player.hp then
      engine.set_draw_color(0, 200, 0, 255)
    else
      engine.set_draw_color(50, 50, 50, 255)
    end
    engine.draw_rect(45 + i * 22, 10, 18, 18)
  end

  engine.set_draw_color(200, 200, 200, 255)
  engine.draw_text("SCORE: " .. game.score, 10, 40)

  engine.set_draw_color(150, 150, 150, 255)
  engine.draw_text("FPS: " .. math.floor(game.fps), 680, 12)

  if game.in_wave_break and not game.game_over then
    engine.set_draw_color(255, 255, 100, 255)
    local time_str = string.format("%.1f", math.max(0, game.wave_break_timer))
    engine.draw_text("WAVE " .. game.wave .. " - NEXT IN " .. time_str .. "s", 280, 280)
  end

  if game.game_over then
    engine.set_draw_color(0, 0, 0, 160)
    engine.draw_rect(240, 240, 320, 120)

    engine.set_draw_color(255, 60, 60, 255)
    engine.draw_text("GAME OVER", 300, 260)

    engine.set_draw_color(220, 220, 220, 255)
    engine.draw_text("PRESS SPACE TO RESTART", 230, 310)
  end
end

return game
