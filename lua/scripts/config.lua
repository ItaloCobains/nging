-- config.lua
-- Centralized configuration for all game constants
-- All tunable parameters are defined here for easy tweaking

return {
  -- World dimensions
  world_w = 1600,                          -- World width in pixels
  world_h = 1200,                          -- World height in pixels

  -- Viewport (camera/display size)
  view_w = 800,                            -- Viewport width in pixels
  view_h = 600,                            -- Viewport height in pixels

  -- Player settings
  player_speed = 200,                      -- Movement speed in px/second
  player_hp = 3,                           -- Starting health points

  -- Power-up mechanics
  powerup_drop_chance = 0.15,              -- 15% chance per enemy killed

  -- Wave system
  wave_enemy_base = 5,                     -- Starting enemies in wave 1
  wave_enemy_growth = 3,                   -- Additional enemies per wave (+3 each)
  wave_break_duration = 4.0,               -- Seconds between waves

  -- Screen shake effects
  shake_damage = {
    amplitude = 6,                         -- Shake distance in pixels (damage)
    duration = 0.3,                        -- Duration in seconds (damage)
  },
  shake_explosion = {
    amplitude = 3,                         -- Shake distance in pixels (explosion)
    duration = 0.15,                       -- Duration in seconds (explosion)
  },

  -- Particle system
  particle_count_death = 12,               -- Particles spawned on enemy death
  particle_count_hit = 4,                  -- Particles spawned on bullet impact
  particle_lifetime = 0.4,                 -- Time for particles to fade out
}
