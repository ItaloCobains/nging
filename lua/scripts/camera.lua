-- camera.lua
-- Viewport camera system with player following and screen shake effects

local camera = {
  -- Viewport position
  x = 0,        -- Top-left corner X
  y = 0,        -- Top-left corner Y

  -- World and viewport sizes
  world_w = 1600,      -- Game world width
  world_h = 1200,      -- Game world height
  view_w = 800,        -- Viewport (screen) width
  view_h = 600,        -- Viewport (screen) height

  -- Screen shake
  shake_x = 0,         -- Current shake offset X
  shake_y = 0,         -- Current shake offset Y
  shake_amp = 0,       -- Current shake amplitude
  shake_timer = 0,     -- Time remaining for shake
}

-- Trigger screen shake effect
-- @param amplitude (number) - Shake distance in pixels
-- @param duration (number) - Duration in seconds
-- @usage: camera.shake(6, 0.3)  -- 6px for 0.3 seconds
function camera.shake(amplitude, duration)
  camera.shake_amp = amplitude
  camera.shake_timer = duration
end

-- Update camera to follow a world position
-- Handles screen shake, player centering, and world boundary clamping
-- @param wx (number) - World X position to center on (player center)
-- @param wy (number) - World Y position to center on (player center)
-- @usage: camera.follow(player.x + player.width/2, player.y + player.height/2)
function camera.follow(wx, wy)
  -- Update screen shake
  if camera.shake_timer > 0 then
    camera.shake_timer = camera.shake_timer - 0.016  -- Decay over ~16ms frame
    -- Calculate shake intensity (fades over time)
    local ratio = camera.shake_timer / camera.shake_amp * 0.1
    if ratio < 0 then ratio = 0 end
    -- Random shake offset (different each frame)
    camera.shake_x = (math.random() * 2 - 1) * camera.shake_amp * ratio
    camera.shake_y = (math.random() * 2 - 1) * camera.shake_amp * ratio
  else
    camera.shake_x = 0
    camera.shake_y = 0
  end

  -- Center camera on target (player position)
  camera.x = wx - camera.view_w / 2
  camera.y = wy - camera.view_h / 2

  -- Clamp camera to world bounds (no black borders)
  camera.x = math.max(0, math.min(camera.world_w - camera.view_w, camera.x))
  camera.y = math.max(0, math.min(camera.world_h - camera.view_h, camera.y))
end

-- Convert world coordinates to screen (viewport) coordinates
-- Accounts for camera position and screen shake offset
-- @param wx (number) - World X
-- @param wy (number) - World Y
-- @return (number, number) - Screen X, Y
-- @usage: local sx, sy = camera.to_screen(enemy.x, enemy.y)
function camera.to_screen(wx, wy)
  return math.floor(wx - camera.x + camera.shake_x),
         math.floor(wy - camera.y + camera.shake_y)
end

-- Check if a world object is visible in the viewport
-- Used for frustum culling to avoid rendering off-screen objects
-- @param wx (number) - Object world X
-- @param wy (number) - Object world Y
-- @param w (number) - Object width
-- @param h (number) - Object height
-- @return (bool) - Is visible?
-- @usage: if camera.is_visible(x, y, w, h) then draw() end
function camera.is_visible(wx, wy, w, h)
  -- Check if bounding box overlaps viewport
  return wx + w > camera.x and wy + h > camera.y
     and wx < camera.x + camera.view_w and wy < camera.y + camera.view_h
end

return camera
