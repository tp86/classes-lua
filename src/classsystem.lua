local constructorkey = {}

local function makenewobjfn(constructor)
  return function(cls, ...)
    local obj = {}
    cls.__index = cls
    setmetatable(obj, cls)
    constructor(obj, ...)
    return obj
  end
end

local function super(obj, ...)
  local class = getmetatable(obj).__index
  local parent = (getmetatable(class) or {}).__index
  local constructor
  repeat
    local parentmt = getmetatable(parent)
    if not parentmt then
      error("super can be used only in classes with constructable ancestor", 2)
    end
    parent = parentmt.__index
    constructor = parentmt[constructorkey]
  until constructor
  constructor(obj, ...)
end

local function setupconstructor(classmt, classdef)
  local constructor = classdef[constructorkey]
  if constructor then
    classmt.__call = makenewobjfn(constructor)
    classmt[constructorkey] = constructor
  end
  classdef[constructorkey] = nil
end

local function setupparent(classmt, parent)
  if parent then
    classmt.__index = parent
  end
end

local function setupmt(classdef, parent)
  local classmt = {}
  setupconstructor(classmt, classdef)
  setupparent(classmt, parent)
  setmetatable(classdef, classmt)
end

local function makeclass(classdef, parent)
  classdef = classdef or {}
  setupmt(classdef, parent)
  return classdef
end

local class = setmetatable({
  extends = function(parent)
    return function(classdef)
      return makeclass(classdef, parent)
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
