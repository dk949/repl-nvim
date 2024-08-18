# repl-nvim


A very simple REPL for Neovim.

Supports Lua and Haskell out of the box, but more languages can be easily added.


## API

Use your preferred package manager to install, then run the `setup` function
(packer.nvim example):


```lua
----

use {
        "dk949/repl-nvim",
        config = function()
            require("repl-nvim").setup()
        end
    }

----
```

The `setup` function accepts options:

```lua
---@class LangConfig
---@field open string[]
---@field refresh string

---@class Options
---@field configs LangConfig[]?
---@field vertical boolean[]?
---@field vsize integer?
---@field hsize integer?

---@param user_opts Options?
function M.setup(user_opts) end
```

* `vertical`: should REPL be vertical by default? (default: false)
* `vsize`: default window width when opening vertically (default: 60)
* `hsize`: default window height when opening horizontally (default: 15)

For `configs`, see [Configuring new languages](#configuring-new-languages)
section below.

### Lua API

To open the REPL from Lua use the `openRepl` function:

```lua
require("repl-nvim").openRepl()
```


`openRepl` supports options:

```lua

---@param user_opts {lang: string?, vertical:boolean?, size:integer?}?
function M.openRepl(user_opts) end
```

* `lang`: which language to open the REPL for (default: `&filetype`)
* `vertical`: overrides vertical in `setup` for this call
* `size`: overrides `vsize` or `hsize` in `setup` for this call

### Vim

```
:[count]ReplOpen[!] [lang]
```

* `count`: same as `size` in Lua API
* `!`: Do the opposite of default `vertical`
* `lang`: same as `lang` in Lua API

### Configuring new languages

Additional language configurations can be passed to `setup` as `configs`, a
table of `lang_name = LangConfig`. Where `lang_name` is the value of `&filetype`
for that language.

```lua
---@class LangConfig
---@field open string[]
---@field refresh string
```

* `open`: Executable and arguments to spawn the REPL
* `refresh`: REPL command to reload current file

In both, `%` will be replaced by the current file name.

Lua and Haskell are currently supported out of the box.
