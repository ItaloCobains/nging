-- Main menu screen

local menu = {
  blink_timer = 0,
  fading = false,
  fade_timer = 0,
}

function menu.init()
  menu.blink_timer = 0
end

function menu.update(dt)
  local input = require("scripts.input")
  input.update()

  if menu.fading then
    menu.fade_timer = menu.fade_timer + dt
    if menu.fade_timer >= 0.4 then
      local weapon_select = require("scripts.weapon_select")
      weapon_select.init()
      engine.update = weapon_select.update
      engine.draw = weapon_select.draw
    end
    return
  end

  menu.blink_timer = menu.blink_timer + dt
  if menu.blink_timer >= 1.0 then
    menu.blink_timer = 0
  end

  if input.just_pressed(engine.keys.SPACE) then
    menu.fading = true
    menu.fade_timer = 0
  end
end

function menu.draw()
  engine.clear(15, 15, 28, 255)

  local p = math.abs(math.sin(menu.blink_timer * 3.14159))
  local br = math.floor(40 + p * 30)
  local bb = math.floor(100 + p * 80)
  engine.set_draw_color(br, 25, bb, 255)
  for i = 0, 3 do
    engine.draw_rect_outline(i, i, 800 - i * 2, 600 - i * 2)
  end

  local grid_color = math.floor(20 + p * 15)
  engine.set_draw_color(grid_color, grid_color, grid_color + 20, 255)
  for x = 0, 800, 50 do
    engine.draw_rect(x, 0, 1, 600)
  end
  for y = 0, 600, 50 do
    engine.draw_rect(0, y, 800, 1)
  end

  engine.set_draw_color(100 + math.floor(p * 155), 150, 255, 255)
  engine.draw_text("N G I N G", 300, 100)

  engine.set_draw_color(200, 200, 200, 255)
  engine.draw_text("2D SHOOTER", 320, 150)

  local blink = math.floor(menu.blink_timer * 2) % 2 == 0
  if blink then
    engine.set_draw_color(255, 255, 100, 255)
  else
    engine.set_draw_color(100, 100, 50, 255)
  end
  engine.draw_text("PRESS SPACE TO START", 250, 400)

  if menu.fading then
    local alpha = math.floor((menu.fade_timer / 0.4) * 255)
    engine.set_draw_color(0, 0, 0, alpha)
    engine.draw_rect(0, 0, 800, 600)
  end
end

return menu
