-- Weapon definitions with fire mechanics

local weapons = {
  order = { "pistol", "shotgun", "laser" },
}

weapons.pistol = {
  name = "Pistol",
  description = "Standard weapon. Fast fire rate.",
  shoot_interval = 0.15,
  rof_display = string.rep(".", math.min(10, math.ceil(2 / 0.15))),
  fire = function(px, py, dx, dy)
    local bullets = require("scripts.bullet")
    bullets.add(px, py, dx, dy, {
      speed = 420,
      color = { r = 255, g = 140, b = 0 },
      damage = 1,
      piercing = false,
    })
  end,
}

weapons.shotgun = {
  name = "Shotgun",
  description = "3-way spread. Slower fire rate.",
  shoot_interval = 0.55,
  rof_display = string.rep(".", math.min(10, math.ceil(2 / 0.55))),
  fire = function(px, py, dx, dy)
    local bullets = require("scripts.bullet")
    local spread = 0.25

    for i = -1, 1 do
      local angle = math.atan(dy, dx) + spread * i
      local ndx = math.cos(angle)
      local ndy = math.sin(angle)
      bullets.add(px, py, ndx, ndy, {
        speed = 340,
        color = { r = 255, g = 165, b = 0 },
        damage = 1,
        piercing = false,
      })
    end
  end,
}

weapons.laser = {
  name = "Laser",
  description = "Piercing beam. Very fast.",
  shoot_interval = 0.80,
  rof_display = string.rep(".", math.min(10, math.ceil(2 / 0.80))),
  fire = function(px, py, dx, dy)
    local bullets = require("scripts.bullet")
    bullets.add(px, py, dx, dy, {
      speed = 700,
      color = { r = 100, g = 200, b = 255 },
      damage = 99,
      piercing = true,
    })
  end,
}

return weapons
