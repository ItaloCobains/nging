local powerup = {}

powerup.types = {
  health = {
    color = {255, 80, 80},
    effect = function(player)
      if player.hp < 3 then
        player.hp = player.hp + 1
      end
    end,
  },
  rapid = {
    color = {255, 220, 0},
    effect = function(player)
      player.rapid_timer = 5.0
      player.shoot_interval = player.base_shoot_interval / 2
    end,
  },
  shield = {
    color = {100, 200, 255},
    effect = function(player)
      player.shielded = true
    end,
  },
}

powerup.list = {}

function powerup.try_drop(x, y)
  if math.random() < 0.15 then
    local types = {"health", "rapid", "shield"}
    local typ = types[math.random(1, #types)]
    table.insert(powerup.list, {
      x = x,
      y = y,
      type = typ,
      w = 14,
      h = 14,
    })
  end
end

function powerup.update(dt, player)
  local to_remove = {}
  for i, pu in ipairs(powerup.list) do
    local dx = pu.x - player.x
    local dy = pu.y - player.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 20 then
      powerup.types[pu.type].effect(player)
      table.insert(to_remove, i)
    end
  end

  for i = #to_remove, 1, -1 do
    table.remove(powerup.list, to_remove[i])
  end
end

function powerup.draw()
  for _, pu in ipairs(powerup.list) do
    local typ = powerup.types[pu.type]
    engine.set_draw_color(typ.color[1], typ.color[2], typ.color[3], 255)
    engine.draw_rect(math.floor(pu.x - 7), math.floor(pu.y - 7), 14, 14)

    local letter = string.sub(pu.type, 1, 1):upper()
    engine.set_draw_color(0, 0, 0, 255)
    engine.draw_text(letter, math.floor(pu.x - 3), math.floor(pu.y - 5))
  end
end

function powerup.clear()
  powerup.list = {}
end

return powerup
