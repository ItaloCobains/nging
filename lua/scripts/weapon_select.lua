-- Weapon selection screen

local weapons = require("scripts.weapons")

local weapon_select = {
  selected_index = 1,
}

function weapon_select.init()
  weapon_select.selected_index = 1
end

function weapon_select.update(dt)
  local input = require("scripts.input")
  input.update()

  if input.just_pressed(engine.keys.UP) then
    weapon_select.selected_index = weapon_select.selected_index - 1
    if weapon_select.selected_index < 1 then
      weapon_select.selected_index = 3
    end
    engine.play_sound("hit")
  end

  if input.just_pressed(engine.keys.DOWN) then
    weapon_select.selected_index = weapon_select.selected_index + 1
    if weapon_select.selected_index > 3 then
      weapon_select.selected_index = 1
    end
    engine.play_sound("hit")
  end

  if input.just_pressed(engine.keys.SPACE) then
    engine.play_sound("pickup")
    local key = weapons.order[weapon_select.selected_index]

    local player = require("scripts.player")
    local game = require("scripts.game")

    player.reset()
    game.start(key)

    engine.update = game.update
    engine.draw = game.draw
  end
end

function weapon_select.draw()
  engine.clear(15, 15, 28, 255)

  engine.set_draw_color(80, 80, 140, 255)
  engine.draw_rect_outline(150, 100, 500, 400)

  engine.set_draw_color(200, 200, 200, 255)
  engine.draw_text("SELECT WEAPON", 300, 120)

  local y_base = 180

  for i, key in ipairs(weapons.order) do
    local weapon = weapons[key]
    local y = y_base + (i - 1) * 80

    if i == weapon_select.selected_index then
      engine.set_draw_color(100, 200, 255, 255)
      engine.draw_rect(160, y - 5, 480, 70)
      engine.set_draw_color(255, 255, 100, 255)
      engine.draw_text(">", 180, y + 10)
    else
      engine.set_draw_color(60, 60, 100, 255)
      engine.draw_rect(160, y - 5, 480, 70)
    end

    engine.set_draw_color(255, 255, 255, 255)
    engine.draw_text(weapon.name, 210, y)
    engine.draw_text(weapon.description, 210, y + 25)

    engine.set_draw_color(200, 200, 150, 255)
    engine.draw_text("ROF: " .. weapon.rof_display, 210, y + 42)
  end

  engine.set_draw_color(150, 150, 150, 255)
  engine.draw_text("PRESS SPACE TO CONFIRM", 240, 540)

  local scores = require("scripts.scores")
  local best = scores.top(1)[1] or 0
  engine.set_draw_color(200, 100, 100, 255)
  engine.draw_text("BEST: " .. best, 320, 560)
end

return weapon_select
