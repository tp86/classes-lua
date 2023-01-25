local runner = not ... or #arg > 0
if runner then
  package.path = table.concat({ "src/?.lua", ".luarocks/share/lua/5.4/?.lua", package.path }, ";")
end
local lu = require "luaunit"

_Test_generic_class = {

  _test_can_be_created = function()
  end,
}

if runner then
  os.exit(lu.LuaUnit.run())
end
