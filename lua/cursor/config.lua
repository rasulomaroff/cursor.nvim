--- @class Cursor.Config
--- @field trigger? Cursor.Trigger
--- @field cursors? (Cursor.Cursor | string)[]
--- @field overwrite_cursor? boolean -- clear default cursor

--- @class Cursor.Trigger
--- @field strategy? Cursor.Strategy
--- @field cursors? (Cursor.Cursor | string)[]

--- @class Cursor.Strategy
--- @field type? 'event' | 'timer' | 'custom'
--- @field timer? Cursor.Strategy.Timer

--- @class Cursor.Strategy.Timer
--- @field delay number -- delay in ms
--- @field events? string | string[] -- additional events to trigger a cursor blinking
--- @field overwrite_events? boolean -- overwrite default events

local default_config = {
    trigger = {
        strategy = nil,
        cursors = nil,
    },
    overwrite_cursor = false,
    cursors = nil,
}

local M = {}

---@param config? Cursor.Config
function M.setup(config)
    config = config and vim.tbl_deep_extend('force', default_config, config) or default_config

    vim.validate {
        trigger = { config.trigger, 't' },
        cursors = { config.cursors, 't', true },
        overwrite_cursor = { config.overwrite_cursor, 'b', true },
    }

    local Cursor = require 'cursor.cursor'
    local Util = require 'cursor.util'

    if config.overwrite_cursor then
        vim.opt.guicursor = ''
    end

    if config.cursors and not vim.tbl_isempty(config.cursors) then
        Cursor:set_constant_cursors(config.cursors)
    end

    local strategy_type
    if config.trigger.strategy then
        strategy_type = config.trigger.strategy.type
    end

    if not Util.has_strategy(strategy_type) then
        return
    end

    vim.validate {
        ['trigger.cursors'] = { config.trigger.cursors, 't' },
    }

    Cursor:set_trigger_cursors(config.trigger.cursors)

    require('cursor.strategy.' .. strategy_type):init(config.trigger.strategy[strategy_type])
end

return M
