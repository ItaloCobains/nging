local pause = {}

pause.active = false

function pause.toggle()
  pause.active = not pause.active
  engine.play_sound("hit")
end

function pause.draw()
  if pause.active then
    engine.set_draw_color(0, 0, 0, 180)
    engine.draw_rect(0, 0, 800, 600)
    engine.set_draw_color(255, 255, 255, 255)
    engine.draw_text("PAUSED", 350, 270)
    engine.draw_text("ESC to resume", 300, 300)
  end
end

return pause
