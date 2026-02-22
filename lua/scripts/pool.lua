local pool_mt = {}

function pool_mt:acquire()
  for _, obj in ipairs(self.objects) do
    if not obj.active then
      obj.active = true
      return obj.data
    end
  end

  local new_obj = {active = true, data = self.factory_fn()}
  table.insert(self.objects, new_obj)
  return new_obj.data
end

function pool_mt:release(obj)
  for _, item in ipairs(self.objects) do
    if item.data == obj then
      item.active = false
      return
    end
  end
end

function pool_mt:each(fn)
  for _, item in ipairs(self.objects) do
    if item.active then
      fn(item.data)
    end
  end
end

function pool_mt:clear()
  for _, item in ipairs(self.objects) do
    item.active = false
  end
end

pool_mt.__index = pool_mt

local pool = {}

function pool.new(size, factory_fn)
  local p = {
    objects = {},
    size = size,
    factory_fn = factory_fn,
  }

  for i = 1, size do
    table.insert(p.objects, {active = false, data = factory_fn()})
  end

  setmetatable(p, pool_mt)
  return p
end

return pool
