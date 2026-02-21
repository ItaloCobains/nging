--- Game state and update/draw callbacks.

local player = require("scripts.player")
local bullets = require("scripts.bullet")
local enemies = require("scripts.enemy")

local game = {
  title = "nging",
  version = "0.1.0",
  score = 0,
  game_over = false,
  spawn_timer = 0,
  spawn_interval = 2.0,
}

function game.update(dt)
  if game.game_over then
    return
  end

  player.update(dt)
  bullets.update(dt)
  enemies.update(dt, player.x + player.width / 2, player.y + player.height / 2)

  game.spawn_timer = game.spawn_timer + dt
  if game.spawn_timer >= game.spawn_interval then
    game.spawn_timer = 0
    game.spawn_enemy()
  end

  game.check_collisions()
end

function game.spawn_enemy()
  local side = math.random(4)
  local x, y

  if side == 1 then
    x = math.random(0, 800)
    y = -20
  elseif side == 2 then
    x = math.random(0, 800)
    y = 620
  elseif side == 3 then
    x = -20
    y = math.random(0, 600)
  else
    x = 820
    y = math.random(0, 600)
  end

  enemies.spawn(x, y)
end

function game.check_collisions()
  for bi = #bullets.list, 1, -1 do
    local bullet = bullets.list[bi]
    for ei = #enemies.list, 1, -1 do
      local enemy = enemies.list[ei]
      if game.aabb(bullet.x, bullet.y, bullets.width, bullets.height,
                   enemy.x, enemy.y, enemies.width, enemies.height) then
        table.remove(bullets.list, bi)
        enemy.hp = enemy.hp - 1
        game.score = game.score + 1
        break
      end
    end
  end

  for ei = #enemies.list, 1, -1 do
    local enemy = enemies.list[ei]
    if game.aabb(player.x, player.y, player.width, player.height,
                 enemy.x, enemy.y, enemies.width, enemies.height) then
      player.take_damage()
      table.remove(enemies.list, ei)
      if player.hp <= 0 then
        game.game_over = true
      end
    end
  end
end

function game.aabb(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
end

function game.draw()
  engine.clear(20, 20, 35, 255)

  engine.set_draw_color(30, 30, 50, 255)
  for x = 0, 800, 50 do
    engine.draw_rect(x, 0, 1, 600)
  end
  for y = 0, 600, 50 do
    engine.draw_rect(0, y, 800, 1)
  end

  engine.set_draw_color(50, 50, 80, 255)
  for i = 2, 5 do
    engine.draw_rect_outline(i, i, 800 - i * 2, 600 - i * 2)
  end

  player.draw()
  bullets.draw()
  enemies.draw()

  game.draw_ui()
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

  if game.game_over then
    engine.set_draw_color(0, 0, 0, 160)
    engine.draw_rect(240, 240, 320, 120)

    engine.set_draw_color(255, 60, 60, 255)
    engine.draw_text("GAME OVER", 300, 260)

    engine.set_draw_color(220, 220, 220, 255)
    engine.draw_text("Press ESC to quit", 260, 310)
  end
end

return game
