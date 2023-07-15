local Util = require 'cursor.util'

--- @class Cursor.Config
--- @field cursors? (Cursor.StaticCursor | string)[]
--- @field blink? Cursor.Strategy
--- @field overwrite_cursor? boolean -- clear default cursor

--- @class Cursors.Config.Blink
--- @field strategy? Cursor.Strategy

--- @alias Cursor.Strategy.Type 'event' | 'timer' | 'always' | 'custom' | 'none'

--- @class Cursor.Strategy
--- @field type? Cursor.Strategy.Type
--- @field timer? Cursor.Strategy.Timer

--- @class Cursor.BlinkCursor
--- @field mode string | string[] -- You can check possible modes by :h 'guicursor'
--- @field size? string | number - string or number from 1 to 100. Only works in GUI.
--- @field shape? 'hor' | 'ver' | 'block' -- stand for horizontal, vertical, and block
--- @field hl? string | [string, string]
--- @field blinkwait number | string
--- @field blinkon number | string
--- @field blinkoff number | string

--- @class Cursor.StaticCursor
--- @field mode string | string[] -- You can check possible modes by :h 'guicursor'
--- @field size string | number - string or number from 1 to 100. Only works in GUI.
--- @field shape 'horizontal' | 'vertical' | 'block'
--- @field hl? string | [string, string]

--- @class Cursor
local M = {}

local default_config = {
    blink = {
        strategy = {
            type = 'timer',
            timer = {
                delay = 5000,
                events = nil,
                overwrite_events = false,
            },
        },
        cursors = {
            { mode = 'a', blinkwait = 100, blinkon = 400, blinkoff = 400 },
        },
    },
    overwrite_cursor = false,
    cursors = nil,
}

--- @param config? Cursor.Config
function M.setup(config)
    -- TODO: reload it if setup is called more than once

    config = config and vim.tbl_deep_extend('force', default_config, config) or default_config

    if config.overwrite_cursor then
        vim.opt.guicursor = ''
    end

    if config.cursors and not vim.tbl_isempty(config.cursors) then
        Util.cursor.set(Util.get_static_cursors(config.cursors))
    end

    -- TODO: validating?
    -- vim.validate {}

    local strategy_type = config.blink.strategy.type

    if strategy_type == 'none' then
        return
    end

    local blink_cursor = Util.get_blink_cursors(config.blink.cursors)

    if strategy_type == 'always' then
        Util.cursor.set(blink_cursor)
    else
        require('cursor.strategy.' .. strategy_type):init(blink_cursor, config.blink.strategy[strategy_type])
    end
end

-- TODO: support reloading
function M.deactivate() end

return M
