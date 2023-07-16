local Util = require 'cursor.util'

--- @alias Cursor.Strategy.Type 'event' | 'timer' | 'custom'

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
--- @field shape 'hor' | 'ver' | 'block' -- stand for horizontal, vertical, and block
--- @field hl? string | [string, string]

local M = {}

--- @param config? Cursor.Config
function M.setup(config)
    -- TODO: reload it if setup is called more than once
    local default_config = require 'cursor.config'

    config = config and vim.tbl_deep_extend('force', default_config, config) or default_config

    if config.overwrite_cursor then
        vim.opt.guicursor = ''
    end

    if config.cursors and not vim.tbl_isempty(config.cursors) then
        Util.set_cursor(Util.get_static_cursors(config.cursors))
    end

    -- TODO: validating?
    -- vim.validate {}

    local strategy_type = config.trigger.strategy.type

    if Util.is_strategy(strategy_type) then
        return
    end

    local triggered_cursor = Util.get_blink_cursors(config.trigger.cursors)

    require('cursor.strategy.' .. strategy_type):init(triggered_cursor, config.trigger.strategy[strategy_type])
end

-- TODO: support reloading
function M.deactivate()
    -- vim.api.nvim_del_augroup_by_id()
end

return M
