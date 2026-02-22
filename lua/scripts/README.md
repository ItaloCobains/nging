# nging - Lua Scripts Documentation

Complete reference for all Lua modules in the nging 2D game engine.

---

## Table of Contents
1. [Core Systems](#core-systems)
2. [Game Logic](#game-logic)
3. [UI & Input](#ui--input)
4. [Utilities](#utilities)

---

## Core Systems

### `main.lua` - Entry Point
**Purpose**: Application entry point, initializes engine and starts menu

**Exports**: None (main execution)

**Key Functions**:
- Loads config and scores at startup
- Sets font (Menlo.ttc, 18pt)
- Initializes audio volume (0.7)
- Switches `engine.update` and `engine.draw` to menu callbacks

**Dependencies**: config, scores, menu

---

### `config.lua` - Configuration Constants
**Purpose**: Centralized tuning parameters for the entire game

**Exports**: Table with properties:
```lua
world_w = 1600              -- World width
world_h = 1200              -- World height
view_w = 800                -- Viewport width
view_h = 600                -- Viewport height
player_speed = 200          -- Player movement speed (px/s)
player_hp = 3               -- Player starting HP
powerup_drop_chance = 0.15  -- 15% chance per enemy
wave_enemy_base = 5         -- Starting enemies per wave
wave_enemy_growth = 3       -- Enemies added per wave
wave_break_duration = 4.0   -- Seconds between waves
shake_damage = {amplitude=6, duration=0.3}      -- Damage shake
shake_explosion = {amplitude=3, duration=0.15}  -- Explosion shake
particle_count_death = 12   -- Particles on enemy death
particle_count_hit = 4      -- Particles on bullet hit
particle_lifetime = 0.4     -- Particle lifetime (seconds)
```

**Usage**: `local config = require("scripts.config")`

---

### `event.lua` - Event Bus (Pub/Sub)
**Purpose**: Decoupled event system for game communication

**Exports**:
- `event.on(name, fn)` - Register listener for event
- `event.emit(name, data)` - Trigger event for all listeners
- `event.clear()` - Remove all listeners

**Events Used**:
- `enemy_died` - Emitted when enemy HP reaches 0
  - Data: `{x, y, type, points, color}`
- `player_damaged` - Emitted when player takes damage
  - Data: `{x, y}`
- `bullet_hit` - Emitted when bullet hits enemy
  - Data: `{x, y}`

**Usage**:
```lua
event.on("enemy_died", function(e)
  print("Enemy died at " .. e.x .. ", " .. e.y)
end)
event.emit("enemy_died", {x=100, y=200, ...})
```

---

### `pool.lua` - Object Pool (Memory Management)
**Purpose**: Generic object pooling for efficient reuse of bullets, enemies, particles

**Exports**:
- `pool.new(size, factory_fn)` - Create new pool
  - `size`: Initial pool size
  - `factory_fn`: Function that creates new objects
  - Returns: Pool object

**Pool Methods**:
- `:acquire()` - Get inactive object or create new one
- `:release(obj)` - Mark object as inactive
- `:each(fn)` - Iterate over active objects
- `:clear()` - Deactivate all objects

**Usage**:
```lua
local my_pool = pool.new(100, function()
  return {x=0, y=0, active=false}
end)
local obj = my_pool:acquire()
my_pool:release(obj)
my_pool:each(function(o) print(o.x) end)
```

---

## Game Logic

### `game.lua` - Core Game State & Loop
**Purpose**: Main game logic, wave system, collision detection, event coordination

**Exports**:
- `game.update(dt)` - Update game state
- `game.draw()` - Render game
- `game.start(weapon_key)` - Initialize new game
- `game.restart_to_weapon_select()` - Return to weapon select
- `game.aabb(x1,y1,w1,h1,x2,y2,w2,h2)` - AABB collision test

**State Variables**:
- `game.score` - Current score
- `game.wave` - Current wave number
- `game.game_over` - Game over flag
- `game.wave_enemies_to_spawn` - Enemies remaining to spawn this wave
- `game.wave_enemies_left` - Enemies remaining to kill
- `game.in_wave_break` - In break between waves
- `game.wave_break_timer` - Break countdown

**Features**:
- Wave system with progressive difficulty
- Event listener setup (enemy_died, player_damaged, bullet_hit)
- Collision detection (bullets ↔ enemies, enemies ↔ player)
- Pause/Debug toggle (ESC/F1)
- FPS counter (exponential moving average)
- Score persistence on game over

**Dependencies**: All game modules

---

### `player.lua` - Player Character
**Purpose**: Player controller, health, shooting, power-up effects

**Exports**:
- `player.update(dt)` - Movement, shooting, cooldowns
- `player.draw()` - Render humanoid silhouette
- `player.take_damage()` - Handle damage (shield/HP)
- `player.reset()` - Reset to initial state
- `player.check_shoot(dt)` - Fire weapon based on arrow input

**Properties**:
- `player.x, player.y` - World position
- `player.speed = 200` - Movement speed (px/s)
- `player.hp` - Current health (1-3)
- `player.width = 24, player.height = 24` - Collision box
- `player.shoot_cooldown` - Weapon cooldown
- `player.active_weapon` - Current weapon
- `player.shielded` - Shield power-up active
- `player.rapid_timer` - Rapid fire countdown

**Input**:
- **Movement**: W/A/S/D
- **Shoot**: Arrow keys (UP/DOWN/LEFT/RIGHT)

**Visual**: 24×24 blue/cyan humanoid with animated legs/arms

---

### `bullet.lua` - Projectile System
**Purpose**: Bullet spawning, movement, rendering, collision

**Exports**:
- `bullets.add(x, y, dx, dy, opts)` - Create bullet
- `bullets.update(dt)` - Update positions, despawn off-screen
- `bullets.draw()` - Render with glow effect
- `bullets.get_all()` - Get all active bullets
- `bullets.hit(bullet)` - Mark bullet as hit

**Bullet Properties**:
- `x, y` - World position
- `dx, dy` - Direction (normalized)
- `speed` - Pixels per second
- `damage` - Damage to enemies
- `piercing` - Ignores first hit
- `color` - RGB for rendering

**Rendering**:
- Directional bullets (14×4 or 4×14)
- Glow effect around nucleus
- Orange color with fade
- Special handling for diagonal movement

**Dependencies**: pool, camera, event

---

### `enemy.lua` - Enemy AI System
**Purpose**: Enemy spawning, AI behavior, death handling

**Exports**:
- `enemies.spawn(x, y, type_name)` - Create enemy
- `enemies.update(dt, px, py)` - Movement, death checks
- `enemies.draw()` - Render enemies
- `enemies.get_all()` - Get all active enemies
- `enemies.clear()` - Deactivate all

**Enemy Types**:
| Type | HP | Speed | Size | Points | Behavior |
|------|----|----|------|--------|----------|
| basic | 1 | 80 | 22×22 | 1 | Simple pursuit |
| scout | 1 | 150 | 16×16 | 2 | Fast pursuit |
| tank | 3 | 50 | 30×30 | 5 | Slow, HP bar |
| zigzagger | 1 | 120 | 18×18 | 3 | Perpendicular oscillation |

**Progressive Spawning**:
- Wave 1: Only basic enemies
- Score ≥10: Scout enemies (30%)
- Score ≥25: Tank enemies (20%)
- Score ≥50: Zigzagger enemies (15%)

**Dependencies**: pool, event, camera

---

### `particle.lua` - Particle Effects
**Purpose**: Visual effects (explosions, impacts)

**Exports**:
- `particle.emit(x, y, opts)` - Create particle burst
- `particle.update(dt)` - Update positions, lifetime
- `particle.draw()` - Render with alpha fade
- `particle.clear()` - Deactivate all

**Options**:
```lua
particle.emit(x, y, {
  count = 12,           -- Number of particles
  speed_min = 50,       -- Min velocity
  speed_max = 150,      -- Max velocity
  color = {255,100,100}, -- RGB
  lifetime = 0.4,       -- Seconds
  size = 2              -- Pixel size
})
```

**Features**:
- Pool of 256 particles
- Random directional velocity
- Alpha fade based on remaining lifetime
- 12 particles on enemy death
- 4 particles on bullet impact

**Dependencies**: pool

---

### `camera.lua` - Viewport Camera
**Purpose**: Viewport tracking, coordinate transformation, screen shake

**Exports**:
- `camera.follow(wx, wy)` - Center on world position
- `camera.to_screen(wx, wy)` - Convert world → screen coords
- `camera.is_visible(wx, wy, w, h)` - Frustum culling check
- `camera.shake(amplitude, duration)` - Trigger screen shake

**Properties**:
- `camera.x, camera.y` - Top-left of viewport
- `camera.world_w = 1600, camera.world_h = 1200` - World bounds
- `camera.view_w = 800, camera.view_h = 600` - Viewport size

**Screen Shake**:
- Damage: 6px amplitude, 0.3s duration
- Explosion: 3px amplitude, 0.15s duration
- Exponential decay over time
- Applied via offset in `to_screen()`

---

## UI & Input

### `input.lua` - Input State Management
**Purpose**: Track input state and edge detection

**Exports**:
- `input.update()` - Update input state each frame
- `input.just_pressed(scancode)` - Was key pressed this frame
- `input.keys[scancode]` - Is key currently held

**Usage**:
```lua
input.update()
if input.just_pressed(engine.keys.SPACE) then
  print("Space pressed!")
end
if engine.is_key_down(engine.keys.W) then
  print("W held")
end
```

---

### `menu.lua` - Main Menu Screen
**Purpose**: Start screen with animations and fade transition

**Exports**:
- `menu.init()` - Initialize menu
- `menu.update(dt)` - Handle input, manage fade
- `menu.draw()` - Render menu

**Features**:
- Animated grid background
- Pulsing border
- Blinking "PRESS SPACE TO START" text
- 0.4s fade-to-black transition before weapon select
- Grid coloring synchronized to border pulse

**State**:
- `menu.blink_timer` - Text blink animation
- `menu.fading` - Transitioning to weapon select
- `menu.fade_timer` - Fade progress (0-0.4s)

---

### `weapon_select.lua` - Weapon Selection Screen
**Purpose**: Choose weapon before game start

**Exports**:
- `weapon_select.init()` - Reset selection
- `weapon_select.update(dt)` - Navigation and confirm
- `weapon_select.draw()` - Render options

**Features**:
- UP/DOWN navigate 3 weapons
- SPACE confirms selection
- Sound effects:
  - "hit" on navigation
  - "pickup" on confirmation
- Display best high score ("BEST: X")
- Weapon descriptions and ROF display

**Input**:
- UP: Previous weapon (with sound)
- DOWN: Next weapon (with sound)
- SPACE: Start game (with sound)

---

### `pause.lua` - Pause System
**Purpose**: Game pause overlay

**Exports**:
- `pause.toggle()` - Toggle pause state
- `pause.draw()` - Render overlay if active

**Properties**:
- `pause.active` - Is game paused

**Features**:
- Semi-transparent black overlay (RGBA 0,0,0,180)
- "PAUSED" text centered
- "ESC to resume" instructions
- Feedback sound on toggle

**Integration**:
- Called from `game.update()` on ESC key
- If paused, game.update() returns early (no updates)
- `pause.draw()` called last in game.draw() to overlay

---

### `debug.lua` - Debug Overlay
**Purpose**: Development information display

**Exports**:
- `debug.draw(game_state)` - Render debug info

**Properties**:
- `debug.visible` - Toggle via F1

**Displays** (when visible):
- Player position (X, Y)
- Player HP
- Wave number
- Enemies spawned vs. alive count
- Bullet count
- FPS (from game_state)

---

## Utilities

### `scores.lua` - High Score Management
**Purpose**: Persistent score storage and retrieval

**Exports**:
- `scores.load()` - Load from scores.dat
- `scores.save()` - Write to scores.dat
- `scores.add(score)` - Add score (auto-save)
- `scores.top(n)` - Get top N scores

**Storage**:
- File: `scores.dat` (one score per line)
- Limit: Top 10 scores
- Format: Plain text numbers, sorted descending

**Usage**:
```lua
scores.load()
scores.add(1500)  -- Saves automatically
local best = scores.top(1)[1]  -- Get highest
```

---

### `powerup.lua` - Power-up System
**Purpose**: Power-up spawning, pickup, effects

**Exports**:
- `powerup.try_drop(x, y)` - 15% spawn chance
- `powerup.update(dt, player)` - Collision & pickup
- `powerup.draw()` - Render as colored squares
- `powerup.clear()` - Deactivate all

**Types**:
| Type | Color | Effect | Duration |
|------|-------|--------|----------|
| health | Red (255,80,80) | +1 HP (max 3) | Instant |
| rapid | Yellow (255,220,0) | 2× fire rate | 5 seconds |
| shield | Blue (100,200,255) | Absorb 1 hit | Until hit |

**Rendering**:
- 14×14 colored square
- First letter (H/R/S) displayed inside
- Collision box: ~20px radius from center

---

### `weapons.lua` - Weapon Definitions
**Purpose**: Weapon properties and firing behavior

**Exports**: Table with weapons:
- `weapons.pistol` - Standard single-shot
- `weapons.shotgun` - 3-way spread
- `weapons.laser` - Piercing high-damage
- `weapons.order` - Array for menu navigation

**Weapon Properties**:
- `name` - Display name
- `description` - Short description
- `rof_display` - Rate of fire text
- `shoot_interval` - Cooldown (seconds)
- `fire(cx, cy, dx, dy)` - Spawn bullets function

**Weapon Specifications**:
| Weapon | Interval | Damage | Speed | Special |
|--------|----------|--------|-------|---------|
| Pistol | 0.15s | 1 | 420 px/s | Single shot |
| Shotgun | 0.55s | 1 | 340 px/s | 3-way spread ±0.25rad |
| Laser | 0.80s | 99 | 700 px/s | Piercing |

**Usage**:
```lua
game.active_weapon = weapons.pistol
game.active_weapon.fire(100, 100, 1, 0)  -- Fire right
```

---

## System Dependencies

### Module Import Graph
```
main.lua
  ├─ config.lua
  ├─ scores.lua
  └─ menu.lua
       └─ weapon_select.lua
            ├─ weapons.lua
            ├─ scores.lua
            └─ game.lua
                 ├─ player.lua
                 ├─ bullet.lua
                 ├─ enemy.lua
                 ├─ camera.lua
                 ├─ input.lua
                 ├─ event.lua
                 ├─ particle.lua
                 ├─ powerup.lua
                 ├─ pause.lua
                 ├─ debug.lua
                 └─ weapons.lua
```

---

## Engine Bindings

All modules have access to global `engine` object with methods:

### Rendering
- `engine.clear(r, g, b, a)` - Clear screen
- `engine.set_draw_color(r, g, b, a)` - Set color
- `engine.draw_rect(x, y, w, h)` - Filled rectangle
- `engine.draw_rect_outline(x, y, w, h)` - Rectangle outline
- `engine.set_font(path, size)` - Load TTF font
- `engine.draw_text(text, x, y)` - Render text

### Input
- `engine.is_key_down(scancode)` - Check if key held
- `engine.get_mouse_pos()` - Get mouse position
- `engine.keys.*` - Scancode constants (W, A, S, D, UP, DOWN, LEFT, RIGHT, SPACE, ESCAPE, F1)

### Audio
- `engine.play_sound(name)` - Play sound (shoot, hit, explosion, pickup, damage, wave)
- `engine.set_sfx_volume(v)` - Volume 0.0-1.0

### Logging
- `engine.log(msg)` - Print to console

---

## Game Flow

```
START
  ↓
main.lua (load config, scores, init volume)
  ↓
menu.lua (show menu, wait for SPACE)
  ↓ [SPACE pressed]
[FADE 0.4s]
  ↓
weapon_select.lua (choose weapon, show best score)
  ↓ [SPACE pressed]
  ↓
game.start(weapon_key)
  ├─ Clear all pools/events/state
  ├─ Setup event listeners
  └─ game.next_wave() [Wave 1]
  ↓
game.update() / game.draw() [Main loop]
  ├─ Wave system (spawn, check completion)
  ├─ Collision detection
  ├─ Update player/enemies/bullets/particles
  ├─ Event handling
  └─ Pause/Debug toggles (ESC/F1)
  ↓ [Enemy defeated]
  ├─ Emit "enemy_died" event
  ├─ Update score
  ├─ Spawn particles
  └─ Chance powerup drop
  ↓ [Wave complete]
  ├─ Start wave break (4s countdown)
  └─ Play "wave" sound
  ↓ [Break complete]
  └─ game.next_wave() [Next wave]
  ↓ [Player HP ≤ 0]
  ├─ Save score
  └─ game.restart_to_weapon_select()
  ↓
[Repeat from weapon_select]
```

---

## Key Constants

**Collision Hitbox**:
- Bullet: 8×8 px
- Player: 24×24 px
- Varies per enemy type

**Timeouts/Durations**:
- Weapon cooldown: Varies (0.15-0.80s)
- Particle lifetime: 0.4s
- Wave break: 4.0s
- Menu fade: 0.4s
- Rapid power-up: 5.0s
- Screen shake decay: Exponential

**Spawn Mechanics**:
- Initial spawn rate: 2.0s
- Minimum spawn rate: 0.5s
- Rate formula: `max(0.5, 2.0 - score * 0.02)`
- Powerup drop: 15% per enemy

**Difficulty Scaling**:
- Wave enemy base: 5
- Wave enemy growth: +3 per wave
- Enemy types unlock at specific scores

