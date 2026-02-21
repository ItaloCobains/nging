-- Entry point executed by the engine on startup.
-- 'engine' table is provided by the C host.

engine.log("nging engine started")

-- Example: define game state
local game = {
    title   = "My 2D Game",
    version = "0.1.0",
}

engine.log(string.format("Loading '%s' v%s", game.title, game.version))
