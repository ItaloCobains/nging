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
  engine.clear(30, 30, 30, 255)

  player.draw()
  bullets.draw()
  enemies.draw()

  game.draw_ui()
end

function game.draw_ui()
  engine.set_draw_color(100, 255, 100, 255)
  local hp_bar_width = player.hp * 30
  engine.draw_rect(10, 10, hp_bar_width, 20)

  engine.set_draw_color(100, 100, 255, 255)
  local score_bar_width = math.min(game.score * 5, 200)
  engine.draw_rect(10, 40, score_bar_width, 20)

  if game.game_over then
    engine.set_draw_color(255, 0, 0, 255)
    engine.draw_rect(350, 280, 100, 40)
  end
end

return game
