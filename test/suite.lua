local runner = not ... or #arg > 0
if runner then
  package.path = table.concat({ "src/?.lua", ".luarocks/share/lua/5.4/?.lua", package.path }, ";")
end

require "test.class"

if runner then
  local lu = require "luaunit"
  os.exit(lu.LuaUnit.run())
end
