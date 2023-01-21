---@diagnostic disable: undefined-global

local class = require "class"

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

local init = class.constructor

describe("class with constructor", function()

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

  it("constructs object with instance methods defined in class", function()
    local Class = class {
      [init] = function(self, x)
        self.x = x
      end,
      getx = function(self) return self.x end,
    }
    local obj = Class(12)
    assert.equal(12, obj:getx())
  end)

  it("throws error if super is used without parent", function()
    local Class = class {
      [init] = function(self)
        class.super(self)()
      end
    }
    assert.has_error(function() Class() end, "super can be used only in classes with constructable ancestor")
  end)
end)

describe("class with parent", function()

  it("can be created", function()
    local Parent = class()
    local Class = class.extends(Parent)()
    assert.is_not_nil(Class)
  end)

  it("can access parent's fields and methods", function()
    local Parent = class {
      field = 1,
      method = function() return 2 end,
    }
    local Class = class.extends(Parent)()
    assert.equal(1, Class.field)
    assert.equal(2, Class.method())
  end)

  it("constructs object that can access parent's fields and methods", function()
    local Parent = class {
      parentfield = 3,
      parentmethod = function() return 4 end,
      parentinstancemethod = function(self) return self.x end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        self.x = 5
      end
    }
    local obj = Class()
    assert.equal(3, obj.parentfield)
    assert.equal(4, obj.parentmethod())
    assert.equal(5, obj:parentinstancemethod())
  end)

  it("can override parent's methods", function()
    local Parent = class {
      method = function(self) return self.x end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        self.x = 6
        self.y = 7
      end,
      method = function(self) return self.y end,
    }
    local obj = Class()
    assert.equal(7, obj:method())
  end)

  it("supports inheritance chain", function()
    local Ancestor = class {
      ancestorfield = 8
    }
    local Parent = class.extends(Ancestor) {
      parentfield = 9
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        self.field = 10
      end
    }
    local obj = Class()
    assert.equal(8, obj.ancestorfield)
    assert.equal(9, obj.parentfield)
    assert.equal(10, obj.field)
  end)

  local super = class.super

  it("can call parent's constructor with parameters", function()
    local Parent = class {
      [init] = function(self, x)
        self.x = x
      end
    }
    local Class = class.extends(Parent) {
      [init] = function(self, x, y)
        super(self)(x)
        self.y = y
      end
    }
    local obj = Class(11, 12)
    assert.equal(11, obj.x)
    assert.equal(12, obj.y)
  end)

  it("calls constructor of first ancestor that has constructor #experimental", function()
    -- this is probably an overkill, should only consider direct parents
    local Ancestor = class {
      [init] = function(self)
        self.x = 15
      end,
    }
    local Parent = class.extends(Ancestor)()
    local Class = class.extends(Parent) {
      [init] = function(self)
        super(self)()
      end,
    }
    local obj = Class()
    assert.equal(15, obj.x)
  end)

  it("can access parent's overridden methods", function()
    local Parent = class {
      method = function() return 13 end,
      instancemethod = function(self) return self.x end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self) self.x = 14 end,
      method = function() return Parent.method() end,
      instancemethod = function(self) return Parent.instancemethod(self) end,
    }
    assert.equal(13, Class.method())
    local obj = Class()
    assert.equal(14, obj:instancemethod())
  end)

  it("calls super starting searching from current class", function()
    local Ancestor = class {
      [init] = function() end,
    }
    local Parent = class.extends(Ancestor) {
      [init] = function(self)
        class.super(self)()
      end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        class.super(self)()
      end
    }
    assert.has_no_error(function() Class() end, "stack overflow")
  end)
end)

describe("class with multiple parents", function()

  it("can be created", function()
    local Parent1 = class()
    local Parent2 = class()
    local Class = class.extends(Parent1, Parent2)()
    assert.is_not_nil(Class)
  end)

  it("can access both parents' fields and methods", function()
    local Parent1 = class {
      field1 = 1,
      method1 = function() return 2 end,
    }
    local Parent2 = class {
      field2 = 3,
      method2 = function() return 4 end,
    }
    local Class = class.extends(Parent1, Parent2)()
    assert.equal(1, Class.field1)
    assert.equal(2, Class.method1())
    assert.equal(3, Class.field2)
    assert.equal(4, Class.method2())
  end)

  it("can override both parents' methods", function()
    local Parent1 = class {
      method1 = function() return 5 end,
    }
    local Parent2 = class {
      method2 = function() return 6 end,
    }
    local Class = class.extends(Parent1, Parent2) {
      method1 = function() return 7 end,
      method2 = function() return 8 end,
    }
    assert.equal(7, Class.method1())
    assert.equal(8, Class.method2())
  end)

  it("inherits methods in extension order", function()
    local Parent1 = class {
      method = function() return 9 end,
    }
    local Parent2 = class {
      method = function() return 10 end,
    }
    local Class = class.extends(Parent1, Parent2)()
    assert.equal(9, Class.method())
  end)

  it("handles diamond inheritance", function()
    local Root = class {
      [init] = function(self)
        self.x = 11
      end,
      inc = function(self)
        self.x = self.x + 1
      end,
    }
    local Parent1 = class.extends(Root)()
    local Parent2 = class.extends(Root)()
    local Class = class.extends(Parent1, Parent2) {
      [init] = function(self)
        class.super(self)()
      end
    }
    local obj = Class()
    obj:inc()
    assert.equal(12, obj.x)
  end)

  it("can call constructor of specified ancestor", function()
    local Ancestor1 = class {
      [init] = function(self)
        self.x = 1
      end,
    }
    local Ancestor2 = class {
      [init] = function(self)
        self.x = 2
      end,
    }
    local Parent = class.extends(Ancestor1, Ancestor2) {
      [init] = function() end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        class.super(self, Ancestor2)()
      end,
    }
    local object = Class()
    assert.equal(2, object.x)
  end)
end)
