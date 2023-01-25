# classes-lua
Simple class system in Lua - my approach

## Development

Written with TDD using busted

```bash
luarocks --lua-version 5.4 --tree .luarocks install busted
```

With LuaUnit:

```bash
luarocks --lua-version 5.4 --tree .luarocks install luaunit
```

Running tests:

```bash
lua test/suite.lua
```
