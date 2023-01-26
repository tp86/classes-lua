# classes-lua
Simple class system in Lua - my approach

## Development

Written with TDD using LuaUnit

### Dependencies
- LuaUnit

### Installation

```bash
luarocks --lua-version 5.4 --tree .luarocks install luaunit
```

### Running tests

```bash
lua -e 'require"setup"' test/suite.lua
```
