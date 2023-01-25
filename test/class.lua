if not ... then
  package.path = table.concat({ "src/?.lua", ".luarocks/share/lua/5.4/?.lua", package.path }, ";")
end
local lu = require "luaunit"

local class = require "class"

Test_class_without_constructor = {

  test_can_be_created = function()
    local Class = class()
    lu.assert_not_nil(Class)
  end,

  test_can_be_created_given_empty_class_definition = function()
    local Class = class {}
    lu.assert_not_nil(Class)
  end,

  test_cannot_be_called_to_construct_object = function()
    local Class = class()
    lu.assert_error(function() Class() end)
  end,

  test_can_be_created_with_fields_and_methods_in_class_definition = function()
    local Class = class {
      field = 1,
      method = function() return 2 end,
    }
    lu.assert_equals(Class.field, 1)
    lu.assert_equals(Class.method(), 2)
  end,
}

local init = class.constructor

Test_class_with_constructor = {

  test_it_can_be_created = function()
    local Class = class {
      [init] = function() end,
    }
    lu.assert_not_nil(Class)
  end,

  test_can_be_called_to_construct_object = function()
    local Class = class {
      [init] = function() end,
    }
    local object = Class()
    lu.assert_not_nil(object)
  end,

  test_constructs_object_in_constructor = function()
    local Class = class {
      [init] = function(self)
        self.x = 3
      end,
    }
    local object = Class()
    lu.assert_equals(object.x, 3)
  end,

  test_constructs_object_that_can_access_class_fields_and_methods = function()
    local Class = class {
      [init] = function() end,
      field = 4,
      method = function() return 5 end,
    }
    local object = Class()
    lu.assert_equals(object.field, 4)
    lu.assert_equals(object.method(), 5)
  end,

  test_can_access_class_fields_and_methods_in_constructor = function()
    local Class = class {
      [init] = function(self)
        self.x = self.field
        self.y = self.method()
      end,
      field = 6,
      method = function() return 7 end,
    }
    local object = Class()
    lu.assert_equals(object.x, 6)
    lu.assert_equals(object.y, 7)
  end,

  test_constructs_object_that_does_not_have_constructor = function()
    local Class = class {
      [init] = function() end,
    }
    local object = Class()
    lu.assert_nil(object[init])
    lu.assert_error(function() object() end)
  end,

  test_constructs_object_based_on_passed_parameters = function()
    local Class = class {
      [init] = function(self, x, y)
        self.x = x
        self.y = y
      end,
    }
    local object = Class(8, 9)
    lu.assert_equals(object.x, 8)
    lu.assert_equals(object.y, 9)
  end,

  test_constructs_separate_objects = function()
    local Class = class {
      [init] = function(self, x)
        self.x = x
      end
    }
    local object1, object2 = Class(10), Class(11)
    lu.assert_not_is(object1, object2)
    lu.assert_equals(object1.x, 10)
    lu.assert_equals(object2.x, 11)
  end,

  test_constructs_separate_objects_that_have_access_to_common_class_fields = function()
    local Class = class {
      [init] = function() end,
      field = {},
    }
    local object1, object2 = Class(), Class()
    lu.assert_not_is(object1, object2)
    lu.assert_equals(object1.field, Class.field)
    lu.assert_equals(object2.field, Class.field)
  end,

  test_constructs_object_with_instance_methods_defined_in_class = function()
    local Class = class {
      [init] = function(self, x)
        self.x = x
      end,
      get = function(self) return self.x end,
    }
    local object = Class(12)
    lu.assert_equals(object:get(), 12)
  end,
}

Test_class_with_parent = {

  test_can_be_created = function()
    local Parent = class()
    local Class = class.extends(Parent)()
    lu.assert_not_nil(Class)
  end,

  test_can_access_parent_fields_and_methods = function()
    local Parent = class {
      field = 1,
      method = function() return 2 end,
    }
    local Class = class.extends(Parent)()
    lu.assert_equals(Class.field, 1)
    lu.assert_equals(Class.method(), 2)
  end,

  test_constructs_object_that_can_access_parent_field_and_methods = function()
    local Parent = class {
      field = 3,
      method = function() return 4 end,
      instancemethod = function(self) return self.x end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        self.x = 5
      end,
    }
    local object = Class()
    lu.assert_equals(object.field, 3)
    lu.assert_equals(object.method(), 4)
    lu.assert_equals(object:instancemethod(), 5)
  end,

  test_can_override_parent_methods = function()
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
    local object = Class()
    lu.assert_equals(object:method(), 7)
  end,

  test_supports_inheritance_chain = function()
    local Ancestor = class {
      ancestorfield = 8,
    }
    local Parent = class.extends(Ancestor) {
      parentfield = 9,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        self.field = 10
      end,
    }
    local object = Class()
    lu.assert_equals(object.ancestorfield, 8)
    lu.assert_equals(object.parentfield, 9)
    lu.assert_equals(object.field, 10)
  end,

  test_can_access_parent_overridden_methods = function()
    local Parent = class {
      method = function() return 13 end,
      instancemethod = function(self) return self.x end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self) self.x = 14 end,
      method = function() return Parent.method() end,
      instancemethod = function(self) return Parent.instancemethod(self) end,
    }
    lu.assert_equals(13, Class.method())
    local object = Class()
    lu.assert_equals(14, object:instancemethod())
  end,

  _test_can_override_ancestor_methods = function()
  end,
}

if not ... then
  os.exit(lu.LuaUnit.run())
end
