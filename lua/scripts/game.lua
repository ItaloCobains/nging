--- Game state and update/draw callbacks.

local game = {
  title = "nging",
  version = "0.1.0",
  x = 100,
  y = 100,
}

function game.update(delta)
  -- update delta for movement later.
end

function game.draw()
  engine.clear(30, 30, 30, 255)
  engine.set_draw_color(255, 200, 100, 255)
  engine.draw_rect(game.x, game.y, 80, 40)
end

return game
