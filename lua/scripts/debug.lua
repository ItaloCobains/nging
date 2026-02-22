local debug = {}

debug.visible = false

function debug.draw(game_state)
  if not debug.visible then
    return
  end

  engine.set_draw_color(255, 255, 255, 255)
  engine.draw_text("DEBUG", 10, 10)
  engine.draw_text("Player: " .. math.floor(game_state.player.x) .. "," .. math.floor(game_state.player.y), 10, 30)
  engine.draw_text("HP: " .. game_state.player.hp, 10, 50)
  engine.draw_text("Wave: " .. game_state.wave, 10, 70)
  engine.draw_text("Enemies left: " .. game_state.wave_enemies_left, 10, 90)
end

return debug
