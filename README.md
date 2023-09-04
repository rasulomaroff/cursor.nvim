# cursor.nvim

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/rasulomaroff/cursor.nvim/ci.yml?branch=main&style=for-the-badge)](https://github.com/rasulomaroff/cursor.nvim/actions/workflows/ci.yml)

## Features

- **Declarative**: configure cursors with ease of lua tables
- **Triggers**: change cursor colors/shape/size/blink on specific triggers
- **Trigger strategies**: select one of two available strategies or build your own
- **Complete**: support for all native cursor settings

## Installation

- With `lazy.nvim`:

```lua
{
  'rasulomaroff/cursor.nvim',
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

- **`mode`** - **required**. mode in which a cursor will be applied, check `:h 'guicursor'`.
- **`shape`** - `'block'` | `'ver'` | `'hor'` - shape of a cursor: block, vertical or horizontal.
- **`size`** - `number` from 1 to 100. Will only work in GUI. Ignored for the `block` shape.
- **`hl`** - `string` | `[string, string]` - Highlight group or groups which will be used to highlight a cursor. If a tuple specified, then the second
  value is used to highlight language mappings. Read more `:h language-mapping`.
- **`replace`** - `boolean` - remove this cursor while a trigger is active. `default`: false.
- **`blink`** - `number` | `false` | `Cursor.Cursor.Blink` - If specified as `number`, then that number will be used for `blinkwait`, `blinkon`, `blinkoff`.
  If specified as `false`, then it will forcely disable blinking (the use-case of this will be presented below). Or can be specified as a table with the following type:

  `Cursor.Cursor.Blink` - **`wait`** - `number` ms - blinkwait - **`on`** - `number` ms - blinkon - **`off`** - `number` ms - blinkoff - **`default`** - `number` ms - this value will be used if any of the fields above aren't specified

  You can read about all of the above options in `:h 'guicursor'`

  > Warn: all of those blink options are supposed to work in GUI. You can still set numbers there to enable blinking in general,
  > but in most cases it won't matter which number you specify. Don't forget if you set `0` for any of those fields, it will
  > disable blinking completely (`:h 'guicursor'`)

### Trigger

**`config.trigger.cursors`**: `table<Cursor.Cursor | string>`

It is an array of cursor strings (`:h 'guicursor'`) or lua tables with the same type as `config.cursors`, except it doesn't
have `replace` property. Every other field is applicable. These cursors will be applied on specific triggers and revoked after those
triggers are gone.

**`config.trigger.strategy.type`**: `'event'` | `'timer'` | `'custom'`

Default: `nil`

Specifies a strategy type.

#### Strategies

**Timer** strategy type - `'timer'`

**`config.trigger.strategy.timer`**: `Cursor.Strategy.Timer`

This field will be used only if `config.trigger.strategy.type='timer'`. It will use a timer to revoke cursors and events to trigger them.
By default cursors are triggered on `CursorMoved` and `CursorMovedI` events, but you can replace/extend them.

`Cursor.Strategy.Timer`

- **`delay`**: `number` - delay in ms after which cursor will be revoked. Default: `5000`.
- **`events`**: `table<string>` - array of events that will trigger cursors applying. They will extend default ones (`CursorMovedI`, `CursorMoved`).
- **`overwrite_events`**: `boolean` - remove default events from the `events` field. Default: `false`.

**Event** strategy type - `'event'`

This type of strategy doesn't have a config. It will be triggered on `CursorMoved` and `CursorMovedI` events and set cursors. Cursors will be unset on
`CursorHold` and `CursorHoldI` events.

> The time between `CursorMoved` and `CursorHold` events are specified by `vim.opt.updatetime`.

**Custom** strategy type - `'custom'`

Custom strategy type allows you to control when cursors are applied and revoked. You can read more on this below.

## Custom trigger

You can build your custom trigger system and then call trigger/revoke methods to apply/delete the cursors you specified:

1. You need to setup the plugin to use the "custom" strategy and specify regular and trigger cursors.

```lua
require('cursor').setup {
  cursors = {
    -- put your regular cursors here
  },
  trigger = {
    strategy = {
      -- use custom strategy
      type = 'custom',
    },
    cursors = {
      -- put cursors that will be set while trigger is active here
    }
  }
```

2. Require the `cursor` table with 2 mentioned methods:

```lua
local cursor = require('cursor.strategy.custom')
```

3. Use those methods with your custom triggers:

- You can use events to trigger your cursors:

```lua
vim.api.nvim_create_autocmd('InsertEnter', {
  callback = cursor.trigger
})

vim.api.nvim_create_autocmd('InsertLeave', {
  callback = cursor.revoke
})
```

- Or you can call methods from anywhere you want

```lua
local function custom()
  -- other code
  cursor.trigger()
  -- other code
end
```

> **Advice**: don't forget about the `replace` property when specifying regular cursors. It will allow you
> to remove those cursors while your triggers are active.

> If you call the `trigger` method twice without calling the `revoke` method between them, nothing bad will happen, cursors won't be applied twice.
> These cases are handled correctly, the same goes to calling the `revoke` method twice.

## Examples

- Set cursors in all mode to have the `block` shape.

```lua
require('cursor').setup {
  overwrite_cursor = true,
  cursors = {
    {
      mode = 'a',
      shape = 'block'
    }
  }
}
```

- The example below will unset blinking on `CursorMoved` and `CursorMovedI` events and set it on `CursorHold` and `CursorHoldI` events.

```lua
require('cursor').setup {
  cursors = {
    {
      mode = 'a',
      blink = { wait = 100, default = 400 },
    },
  },
  trigger = {
    strategy = {
      type = 'event',
    },
    cursors = {
      {
        mode = 'a',
        blink = false,
      },
    },
  },
}
```

- The example below will highlight your cursor on the same events as the example above and remove highlights as well.

```lua
require('cursor').setup {
  trigger = {
    strategy = {
      type = 'event'
    },
    cursors = {
      {
        mode = 'a',
        hl = 'YourHighlight'
      }
    }
  }
}
```

- Revoke trigger cursors after 10 seconds after triggering

```lua
require('cursor').setup {
  cursors = {
    {
      mode = 'a',
      shape = 'block'
    },
  },
  trigger = {
    strategy = {
      type = 'timer',
      timer = {
        delay = 10000
      }
    },
    cursors = {
      {
        mode = 'a',
        blink = 500,
        hl = 'YourHighlight'
      }
    }
  }
}
```

## Terminals & GUI

### Terminals

- WezTerm - blinking times don't affect cursor blinking times, which is expected, but blinking overall works. You can configure blinking delay in the WezTerm config file. Tested on MacOS.
- Alacritty - blinking stops after several blinks even without using this plugin, not sure why. Tested on MacOS.
- iTerm - the same as WezTerm.

### GUIs

- Neovide - everything works perfectly. Tested on MacOS.
