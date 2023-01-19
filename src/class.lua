local constructorkey = {}
local parentskey = {}

local function makenewobj(class, ...)
  local object = {}
  class.__index = class
  setmetatable(object, class)
  local constructor = getmetatable(class)[constructorkey]
  if constructor then
    constructor(object, ...)
  end
  return object
end

local function handleparents(class, handler)
  local parents = getmetatable(class)[parentskey]
  if parents then
    return handler(parents)
  end
end

local function getfirstconstructor(class)
  return handleparents(class, function(parents)
    local constructor
    for _, parent in ipairs(parents) do
      local parentmt = getmetatable(parent)
      constructor = parentmt[constructorkey]
      if constructor then return constructor end
      constructor = getfirstconstructor(parent)
      if constructor then return constructor end
    end
  end)
end

local function super(object, ...)
  local class = getmetatable(object).__index
  local constructor = getfirstconstructor(class)
  if not constructor then
    error("super can be used only in classes with constructable ancestor", 2)
  end
  constructor(object, ...)
end

local function setupconstructor(classmt, class)
  local constructor = class[constructorkey]
  if constructor then
    classmt[constructorkey] = constructor
    classmt.__call = makenewobj
  end
  class[constructorkey] = nil
end

local function parentsindex(class, key)
  return handleparents(class, function(parents)
    for _, parent in ipairs(parents) do
      local value = parent[key]
      if value then return value end
    end
  end)
end

local function setupparents(classmt, parents)
  if parents then
    classmt[parentskey] = parents
    classmt.__index = parentsindex
  end
end

local function setupmt(class, parents)
  local classmt = {}
  setupconstructor(classmt, class)
  setupparents(classmt, parents)
  setmetatable(class, classmt)
end

local function copytable(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    copy[k] = v
  end
  return copy
end

local function makeclass(classdef, parents)
  classdef = classdef or {}
  local class = copytable(classdef)
  setupmt(class, parents)
  return class
end

local class = setmetatable({
  extends = function(...)
    local parents = { ... }
    return function(classdef)
      return makeclass(classdef, parents)
    end
  end,
  super = super,
  constructor = constructorkey,
}, {
  __call = function(_, classdef)
    return makeclass(classdef)
  end
})

return class
