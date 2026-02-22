---Engine API provided by the C host. This file is for IDE only (no require).
---@class engine
engine = {}

---@param msg string
function engine.log(msg) end

---@param r number
---@param g number
---@param b number
---@param a number|nil
function engine.clear(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number|nil
function engine.set_draw_color(r, g, b, a) end

---@param x number
---@param y number
---@param w number
---@param h number
function engine.draw_rect(x, y, w, h) end

---@param x number
---@param y number
---@param w number
---@param h number
function engine.draw_rect_outline(x, y, w, h) end

---@param path string
---@param size number
function engine.set_font(path, size) end

---@param text string
---@param x number
---@param y number
function engine.draw_text(text, x, y) end

---@param scancode number SDL scancode
---@return boolean
function engine.is_key_down(scancode) end

---@return number x, number y
function engine.get_mouse_pos() end

---Key constants
---@class engineKeys
---@field W number
---@field A number
---@field S number
---@field D number
---@field UP number
---@field DOWN number
---@field LEFT number
---@field RIGHT number
---@field SPACE number
---@field ESCAPE number
---@field F number
engine.keys = {}

---Called every frame by the C loop.
---@param dt number
function engine.update(dt) end

---Called every frame by the C loop.
function engine.draw() end

---@param volume number
function engine.set_sfx_volume(volume) end

---@param name string
function engine.play_sound(name) end
