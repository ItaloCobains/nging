-- Entry point. Registers game.update and game.draw with the engine.


if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local game = require("scripts.game")

engine.log("nging engine started")
engine.log(string.format("Loading '%s' v%s", game.title, game.version))

engine.update = game.update
engine.draw = game.draw
