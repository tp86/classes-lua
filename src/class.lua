local constructorkey = {}
local parentskey = {}

local function getclassconstructor(class)
  local classmt = getmetatable(class)
  return classmt[constructorkey]
end

local function makenewobj(class, ...)
  local object = {}
  class.__index = class
  setmetatable(object, class)
  local constructor = getclassconstructor(class)
  if constructor then
    constructor(object, ...)
  end
  return object
end

local function setupconstructor(classmt, class)
  local constructor = class[constructorkey]
  if constructor then
    classmt[constructorkey] = constructor
    classmt.__call = makenewobj
  end
  class[constructorkey] = nil
end

local function handleparents(class, handler)
  local parents = getmetatable(class)[parentskey]
  if parents then
    return handler(parents)
  end
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

local function getparentconstructors(class)
  return handleparents(class, function(parents)
    local constructors = {}
    for _, parent in ipairs(parents) do
      local constructor = getclassconstructor(parent)
      if constructor then
        table.insert(constructors, { parent, constructor })
      end
    end
    return constructors
  end)
end

local parentstack = {}

local function parentconstructorcall(constructor, class, object, ...)
  table.insert(parentstack, class)
  constructor(object, ...)
  table.remove(parentstack)
end

local function getfirstparentconstructor(parentconstructors)
  local first = parentconstructors[1] or {}
  return first[1], first[2]
end

local function findparentconstructor(parentconstructors, parent)
  for _, parentconstructor in ipairs(parentconstructors) do
    if parentconstructor[1] == parent then
      return table.unpack(parentconstructor)
    end
  end
end

local function getparentconstructor(class, parent)
  local parentconstructors = getparentconstructors(class)
  if not parent then
    return getfirstparentconstructor(parentconstructors)
  else
    return findparentconstructor(parentconstructors, parent)
  end
end

local function initparent(object, requestedparent)
  return function(...)
    local class = parentstack[#parentstack] or getmetatable(object).__index
    local parentclass, constructor = getparentconstructor(class, requestedparent)
    if not constructor then
      error("parent constructor not found", 2)
    end
    parentconstructorcall(constructor, parentclass, object, ...)
  end
end

local class = setmetatable({
  extends = function(...)
    local parents = { ... }
    return function(classdef)
      return makeclass(classdef, parents)
    end
  end,
  parent = initparent,
  constructor = constructorkey,
}, {
  __call = function(_, classdef)
    return makeclass(classdef)
  end
})

return class
