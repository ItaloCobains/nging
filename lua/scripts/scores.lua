local scores = {}

local FILE = "scores.dat"
scores.list = {}

function scores.load()
  local f = io.open(FILE, "r")
  if f then
    for line in f:lines() do
      local n = tonumber(line)
      if n then
        table.insert(scores.list, n)
      end
    end
    f:close()
    table.sort(scores.list, function(a, b) return a > b end)
  end
end

function scores.save()
  local f = io.open(FILE, "w")
  if f then
    for i = 1, math.min(10, #scores.list) do
      f:write(scores.list[i] .. "\n")
    end
    f:close()
  end
end

function scores.add(n)
  table.insert(scores.list, n)
  table.sort(scores.list, function(a, b) return a > b end)
  if #scores.list > 10 then
    table.remove(scores.list, 11)
  end
  scores.save()
end

function scores.top(n)
  local result = {}
  for i = 1, math.min(n, #scores.list) do
    table.insert(result, scores.list[i])
  end
  return result
end

return scores
