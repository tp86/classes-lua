if not ... then
  package.path = table.concat({ "src/?.lua", ".luarocks/share/lua/5.4/?.lua", package.path }, ";")
end

require "test.class"

if not ... then
  local lu = require "luaunit"
  os.exit(lu.LuaUnit.run())
end
