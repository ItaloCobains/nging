-- Entry point. Registers game.update and game.draw with the engine.


if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

package.path = package.path .. ";lua/?.lua"

local game = require("scripts.game")

engine.log("nging engine started")
engine.log(string.format("Loading '%s' v%s", game.title, game.version))

engine.set_font("/System/Library/Fonts/Menlo.ttc", 18)

engine.update = game.update
engine.draw = game.draw
