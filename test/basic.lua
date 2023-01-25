---@diagnostic disable: lowercase-global
if not ... then
  package.path = table.concat({ "src/?.lua", ".luarocks/share/lua/5.4/?.lua", package.path }, ";")
end
local lu = require "luaunit"

function test_basic()
  lu.assertTrue(true)
end

if not ... then
  os.exit(lu.LuaUnit.run())
end
