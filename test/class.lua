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

  test_can_override_ancestor_methods = function()
    local Ancestor = class {
      method = function() return 15 end,
    }
    local Parent = class.extends(Ancestor)()
    local Class = class.extends(Parent) {
      [init] = function() end,
      method = function() return 16 end,
    }
    local object = Class()
    lu.assert_equals(object.method(), 16)
  end,
}

Test_class_with_multiple_parents = {

  test_can_be_created = function()
    local Parent1 = class()
    local Parent2 = class()
    local Class = class.extends(Parent1, Parent2)()
    lu.assert_not_nil(Class)
  end,

  test_can_access_both_parents_fields_and_methods = function()
    local Parent1 = class {
      field1 = 1,
      method1 = function() return 2 end,
    }
    local Parent2 = class {
      field2 = 3,
      method2 = function() return 4 end,
    }
    local Class = class.extends(Parent1, Parent2)()
    lu.assert_equals(Class.field1, 1)
    lu.assert_equals(Class.method1(), 2)
    lu.assert_equals(Class.field2, 3)
    lu.assert_equals(Class.method2(), 4)
  end,

  test_can_override_both_parents_methods = function()
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
    lu.assert_equals(Class.method1(), 7)
    lu.assert_equals(Class.method2(), 8)
  end,

  test_inherits_methods_in_extension_order = function()
    local Parent1 = class {
      method = function() return 9 end,
    }
    local Parent2 = class {
      method = function() return 10 end,
    }
    local Class = class.extends(Parent1, Parent2)()
    lu.assert_equals(Class.method(), 9)
  end,
}

Test_class_with_parent_constructor_calls = {

  test_calls_first_constructor_found_among_direct_parents = function()
    local Ancestor = class {
      [init] = function(self)
        self.x = 1
      end,
    }
    local Parent1 = class.extends(Ancestor)()
    local Parent2 = class {
      [init] = function(self)
        self.x = 2
      end,
    }
    local Class = class.extends(Parent1, Parent2) {
      [init] = function(self)
        class.parent(self)()
      end,
    }
    local object = Class()
    lu.assert_equals(object.x, 2)
  end,

  test_throws_error_if_parent_class_does_not_have_constructor = function()
    local Ancestor = class {
      [init] = function(self)
        self.x = 3
      end,
    }
    local Parent = class.extends(Ancestor)()
    local Class = class.extends(Parent) {
      [init] = function(self)
        class.parent(self)()
      end,
    }
    lu.assert_error_msg_contains("parent constructor not found", function() Class() end)
  end,

  test_calls_parent_constructor_with_parameters = function()
    local Parent = class {
      [init] = function(self, x)
        self.x = x
      end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self, x)
        class.parent(self)(x)
      end,
    }
    local object = Class(4)
    lu.assert_equals(object.x, 4)
  end,

  test_supports_chained_constructors = function()
    local Ancestor = class {
      [init] = function() end,
    }
    local Parent = class.extends(Ancestor) {
      [init] = function(self)
        class.parent(self)()
      end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        class.parent(self)()
      end,
    }
    lu.assert_true(pcall(function() Class() end))
  end,

  test_calls_specified_parent_constructor = function()
    local Parent1 = class {
      [init] = function(self)
        self.x = 5
      end,
    }
    local Parent2 = class {
      [init] = function(self)
        self.x = 6
      end,
    }
    local Parent3 = class {
      [init] = function(self)
        self.x = 7
      end,
    }
    local Class = class.extends(Parent1, Parent2, Parent3) {
      [init] = function(self)
        class.parent(self, Parent2)()
      end,
    }
    local object = Class()
    lu.assert_equals(object.x, 6)
  end,

  test_throws_error_if_specified_parent_class_is_not_a_parent = function()
    local Ancestor = class {
      [init] = function() end,
    }
    local Parent = class.extends(Ancestor) {
      [init] = function() end,
    }
    local Class = class.extends(Parent) {
      [init] = function(self)
        class.parent(self, Ancestor)()
      end,
    }
    lu.assert_error_msg_contains("parent constructor not found", function() Class() end)
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
