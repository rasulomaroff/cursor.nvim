# cursor.nvim

![cursor nvim](https://github.com/CommuNvim/cursor.nvim/assets/80093436/a163e0f1-07fd-4816-a11a-33a09d0cef33)

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

## Features

- **Declarative**: configure cursors with ease of lua tables
- **Triggers**: change cursor colors/shape/size/blink on specific triggers
- **Trigger strategies**: select one of two available strategies or build your own

## Installation

- With `lazy.nvim`: 
```lua
{
  'CommuNvim/cursor.nvim',
  event = 'VeryLazy',
  opts = {
    -- Your options go here
  }
}
```

## Configuration

### Default config

```lua
---@type Cursor.Config
{
  overwrite_cursor = false,
  cursors = nil,
  trigger = {
    strategy = nil,
    cursors = nil,
  },
}
```

### Config options

**`config.overwrite_cursor`**: `boolean`
Default: `false`.

If `true`, then it will clear `vim.opt.guicursor` when the `setup` method is called. This allows you to configure
cursors from scratch.

**`config.cursors`**: `table<string | Cursor.Cursor>`

It is an array of cursor strings (`:h 'guicursor'`) or lua tables with the following type:

`Cursor.Cursor`

- **`* mode`** - mode in which a cursor will be applied, check `:h 'guicursor'`.
- **`shape`** - `'block'` | `'ver'` | `'hor'` - shape of a cursor: block, vertical or horizontal.
- **`size`** - `number` from 1 to 100. Will only work in GUI. Ignored for the `block` shape.
- **`hl`** - `string` | `[string, string]` - Highlight group or groups which will be used to highlight a cursor. If a tuple specified, then the second
value is used to highlight language mappings. Read more `:h language-mapping`.
- **`replace`** - `boolean` - remove this cursor while a trigger is active. `default`: false.
- **`blink`** - `number` | `false` | `Cursor.Cursor.Blink` - If specified as `number`, then that number will be used for `blinkwait`, `blinkon`, `blinkoff`.
If specified as `false`, then it will forcely disable blinking (the use-case of this will be presented below). Or can be specified as a table with the following type:

  `Cursor.Cursor.Blink`
    - **`wait`** - `number` ms - blinkwait
    - **`on`** - `number` ms - blinkon
    - **`off`** - `number` ms - blinkoff
    - **`freq`** - `number` ms - this value will be used if any of the above fields aren't specified

  You can read about all of the above options in `:h 'guicursor'`
  
  > Warn: all of those blink options are supposed to work in GUI. You can still set numbers there to enable blinking in general,
  > but in most cases it won't matter which number you specify. Don't forget if you set `0` for any of those fields, it will
  > disable blinking completely (`:h 'guicursor'`)

## Custom trigger

## Examples

## Terminals & GUI

### Terminals

- WezTerm - blinking times don't affect cursor blinking times, which is expected, but blinking overall works. You can configure blinking delay in the WezTerm config file. Tested on MacOS.
- Alacritty - blinking stops after several blinks even without using this plugin, not sure why. Tested on MacOS.
- iTerm - the same as WezTerm.

### GUIs

- Neovide - eveyrything works perfectly. Tested on MacOS.
