local function makemt(constructor)
  return {
    __call = function(cls)
      local obj = {}
      setmetatable(obj, cls)
      constructor(obj)
      return obj
    end,
  }
end

local constructor = {}

local function handleconstructor(classdef)
  if classdef[constructor] then
    local classmt = makemt(classdef[constructor])
    setmetatable(classdef, classmt)
    classdef[constructor] = nil
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
  constructor = constructor,
}
