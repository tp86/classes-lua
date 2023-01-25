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
}

if not ... then
  os.exit(lu.LuaUnit.run())
end
