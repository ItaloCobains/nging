-- Entry point. Registers game.update and game.draw with the engine.


if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

package.path = package.path .. ";lua/?.lua"

engine.log("nging engine started")

engine.set_font("/System/Library/Fonts/Menlo.ttc", 18)

local config = require("scripts.config")
local scores = require("scripts.scores")
scores.load()
engine.set_sfx_volume(0.7)

local menu = require("scripts.menu")
menu.init()
engine.update = menu.update
engine.draw = menu.draw
