-- scores.lua
-- High score management with persistent file storage
-- Saves top 10 scores to scores.dat

local scores = {}

-- File path for persistent score storage
local FILE = "scores.dat"

-- In-memory list of scores (sorted descending)
scores.list = {}

-- Load scores from file
-- Called at game startup in main.lua
-- @usage: scores.load()
function scores.load()
  local f = io.open(FILE, "r")
  if f then
    -- Read all lines from file
    for line in f:lines() do
      local n = tonumber(line)
      if n then
        table.insert(scores.list, n)
      end
    end
    f:close()
    -- Sort in descending order (highest first)
    table.sort(scores.list, function(a, b) return a > b end)
  end
end

-- Save scores to file
-- Persists top 10 scores to scores.dat
-- Called automatically by scores.add()
-- @usage: scores.save()
function scores.save()
  local f = io.open(FILE, "w")
  if f then
    -- Write top 10 scores (one per line)
    for i = 1, math.min(10, #scores.list) do
      f:write(scores.list[i] .. "\n")
    end
    f:close()
  end
end

-- Add a new score
-- Inserts into sorted list and saves to file
-- Called when game ends (game.restart_to_weapon_select)
-- @param n (number) - Score to add
-- @usage: scores.add(game.score)
function scores.add(n)
  table.insert(scores.list, n)
  -- Keep list sorted (highest first)
  table.sort(scores.list, function(a, b) return a > b end)
  -- Keep only top 10
  if #scores.list > 10 then
    table.remove(scores.list, 11)
  end
  scores.save()  -- Persist to disk
end

-- Get top N scores
-- Returns array of highest scores
-- @param n (number) - How many top scores to return
-- @return (table) - Array of top N scores
-- @usage: local best = scores.top(1)[1]  -- Get highest score
function scores.top(n)
  local result = {}
  for i = 1, math.min(n, #scores.list) do
    table.insert(result, scores.list[i])
  end
  return result
end

return scores
