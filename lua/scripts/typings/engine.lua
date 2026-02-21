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

---Called every frame by the C loop.
---@param dt number
function engine.update(dt) end

---Called every frame by the C loop.
function engine.draw() end
