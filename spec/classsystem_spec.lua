---@diagnostic disable: undefined-global

local class = require "classsystem".class

describe("class without constructor", function()

  it("can be created", function()
    local Class = class()
    assert.is_not_nil(Class)
  end)

  it("can be created given empty class definition", function()
    local Class = class {}
    assert.is_not_nil(Class)
  end)

  it("cannot be called to construct object", function()
    local Class = class()
    assert.has_error(function() Class() end)
  end)

  it("can be created with fields and methods in class definition", function()
    local Class = class {
      field = 1,
      method = function() return 2 end,
    }
    assert.equal(1, Class.field)
    assert.equal(2, Class.method())
  end)
end)

describe("class with constructor", function()

  local init = require "classsystem".constructor

  it("can be created", function()
    local Class = class {
      [init] = function() end
    }
    assert.is_not_nil(Class)
  end)

  it("can be called to construct object", function()
    local Class = class {
      [init] = function() end
    }
    local obj = Class()
    assert.is_not_nil(obj)
  end)

  it("constructs object in constructor", function()
    local Class = class {
      [init] = function(self)
        self.x = 3
      end
    }
    local obj = Class()
    assert.equal(3, obj.x)
  end)

  it("constructs object that can access class' fields and methods", function()
    local Class = class {
      [init] = function() end,
      field = 4,
      method = function() return 5 end,
    }
    local obj = Class()
    assert.equal(4, obj.field)
    assert.equal(5, obj.method())
  end)

  it("can access class' fields and methods in constructor", function()
    local Class = class {
      [init] = function(self)
        self.x = self.field
        self.y = self.method()
      end,
      field = 6,
      method = function() return 7 end,
    }
    local obj = Class()
    assert.equal(6, obj.x)
    assert.equal(7, obj.y)
  end)

  it("constructs object that does not have constructor", function()
    local Class = class {
      [init] = function() end
    }
    local obj = Class()
    assert.is_nil(obj[init])
    assert.has_error(function() obj() end)
  end)

  it("constructs objects based on passed parameters", function()
    local Class = class {
      [init] = function(self, x, y)
        self.x = x
        self.y = y
      end
    }
    local obj = Class(8, 9)
    assert.equal(8, obj.x)
    assert.equal(9, obj.y)
  end)

  it("constructs separate objects", function()
    local Class = class {
      [init] = function(self, x)
        self.x = x
      end
    }
    local obj1, obj2 = Class(10), Class(11)
    assert.are_not_equal(obj1, obj2)
    assert.equal(10, obj1.x)
    assert.equal(11, obj2.x)
  end)

  it("constructs separate objects that have access to common class' fields", function()
    local Class = class {
      [init] = function() end,
      field = {},
    }
    local obj1, obj2 = Class(), Class()
    assert.are_not_equal(obj1, obj2)
    assert.equal(Class.field, obj1.field)
    assert.equal(Class.field, obj2.field)
  end)
end)
