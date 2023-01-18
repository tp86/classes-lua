local function makemt(constructor)
  return {
    __call = function(cls, ...)
      local obj = {}
      setmetatable(obj, cls)
      constructor(obj, ...)
      return obj
    end,
  }
end

local constructorkey = {}

local function handleconstructor(classdef)
  local constructor = classdef[constructorkey]
  if constructor then
    local classmt = makemt(constructor)
    setmetatable(classdef, classmt)
    classdef[constructorkey] = nil
  end
end

local function class(classdef)
  classdef = classdef or {}
  classdef.__index = classdef
  handleconstructor(classdef)
  return classdef
end

return {
  class = class,
  constructor = constructorkey,
}
