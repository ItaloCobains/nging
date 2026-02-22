-- pool.lua
-- Generic object pooling system for efficient memory reuse
-- Used for bullets, enemies, and particles to avoid constant allocation/deallocation

local pool_mt = {}  -- Metatable for pool methods

-- Acquire an object from the pool
-- Returns an inactive object or creates a new one if pool is exhausted
-- @return (object) - A reusable object from the pool
-- @usage: local bullet = bullet_pool:acquire()
function pool_mt:acquire()
  -- Search for an inactive object
  for _, obj in ipairs(self.objects) do
    if not obj.active then
      obj.active = true
      return obj.data  -- Return the actual object (not wrapper)
    end
  end

  -- If no inactive objects, create a new one (expand pool)
  local new_obj = {active = true, data = self.factory_fn()}
  table.insert(self.objects, new_obj)
  return new_obj.data
end

-- Release an object back to the pool
-- Mark it as inactive so it can be reused
-- @param obj (object) - The object to release
-- @usage: bullet_pool:release(bullet)
function pool_mt:release(obj)
  -- Find the wrapper object and mark inactive
  for _, item in ipairs(self.objects) do
    if item.data == obj then
      item.active = false
      return
    end
  end
end

-- Iterate over all active objects in the pool
-- Only calls function for objects that are currently in use
-- @param fn (function) - Callback function(obj) for each active object
-- @usage: bullet_pool:each(function(b) b.x = b.x + b.vx end)
function pool_mt:each(fn)
  for _, item in ipairs(self.objects) do
    if item.active then  -- Only process active objects
      fn(item.data)
    end
  end
end

-- Deactivate all objects in the pool
-- Used when restarting game or clearing a system
-- @usage: bullet_pool:clear()
function pool_mt:clear()
  for _, item in ipairs(self.objects) do
    item.active = false  -- Mark all as inactive
  end
end

-- Set up method resolution for pool objects
pool_mt.__index = pool_mt

local pool = {}

-- Create a new object pool
-- @param size (number) - Initial pool size
-- @param factory_fn (function) - Function that creates new objects
-- @return (pool) - A new pool object with acquire/release/each/clear methods
-- @usage: local my_pool = pool.new(200, function() return {x=0,y=0,active=false} end)
function pool.new(size, factory_fn)
  local p = {
    objects = {},        -- List of {active=bool, data=object}
    size = size,         -- Initial pool size
    factory_fn = factory_fn,  -- Function to create new objects
  }

  -- Pre-allocate the initial pool
  for i = 1, size do
    table.insert(p.objects, {active = false, data = factory_fn()})
  end

  setmetatable(p, pool_mt)  -- Attach methods via metatable
  return p
end

return pool
