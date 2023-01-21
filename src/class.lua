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

local function getclassconstructor(class)
  local classmt = getmetatable(class)
  return classmt[constructorkey]
end

local function getfirstconstructor(class)
  return handleparents(class, function(parents)
    local constructor
    for _, parent in ipairs(parents) do
      constructor = getclassconstructor(parent)
      if constructor then return constructor, parent end
      local constructorclass
      constructor, constructorclass = getfirstconstructor(parent)
      if constructor then return constructor, constructorclass end
    end
  end)
end

local superstack = {}

local function constructorsupercall(constructor, constructorclass, object, ...)
  table.insert(superstack, constructorclass)
  constructor(object, ...)
  table.remove(superstack)
end

local function super(object, ancestor)
  if ancestor then
    -- XXX buggy: assumes that ancestor has constructor and is really an ancestor of object
    -- TODO tests for above cases
    return function(...)
      constructorsupercall(getclassconstructor(ancestor), ancestor, object, ...)
    end
  else
    return function(...)
      local class = superstack[#superstack] or getmetatable(object).__index
      local constructor, constructorclass = getfirstconstructor(class)
      if not constructor then
        error("super can be used only in classes with constructable ancestor", 3)
      end
      constructorsupercall(constructor, constructorclass, object, ...)
    end
  end
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
