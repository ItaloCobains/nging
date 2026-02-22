-- Camera system with viewport tracking

local camera = {
  x = 0,
  y = 0,
  world_w = 1600,
  world_h = 1200,
  view_w = 800,
  view_h = 600,
  shake_x = 0,
  shake_y = 0,
  shake_amp = 0,
  shake_timer = 0,
}

function camera.shake(amplitude, duration)
  camera.shake_amp = amplitude
  camera.shake_timer = duration
end

function camera.follow(wx, wy)
  if camera.shake_timer > 0 then
    camera.shake_timer = camera.shake_timer - 0.016
    local ratio = camera.shake_timer / camera.shake_amp * 0.1
    if ratio < 0 then ratio = 0 end
    camera.shake_x = (math.random() * 2 - 1) * camera.shake_amp * ratio
    camera.shake_y = (math.random() * 2 - 1) * camera.shake_amp * ratio
  else
    camera.shake_x = 0
    camera.shake_y = 0
  end

  camera.x = wx - camera.view_w / 2
  camera.y = wy - camera.view_h / 2
  camera.x = math.max(0, math.min(camera.world_w - camera.view_w, camera.x))
  camera.y = math.max(0, math.min(camera.world_h - camera.view_h, camera.y))
end

function camera.to_screen(wx, wy)
  return math.floor(wx - camera.x + camera.shake_x), math.floor(wy - camera.y + camera.shake_y)
end

function camera.is_visible(wx, wy, w, h)
  return wx + w > camera.x and wy + h > camera.y
     and wx < camera.x + camera.view_w and wy < camera.y + camera.view_h
end

return camera
