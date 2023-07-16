local Util = require 'cursor.util'
local Cursor = require 'cursor.cursor'

local M = {}

--- @param config? Cursor.Config
function M.setup(config)
    -- TODO: reload it if setup is called more than once

    -- TODO: validating?
    -- vim.validate {}
    local default_config = require 'cursor.config'

    config = config and vim.tbl_deep_extend('force', default_config, config) or default_config

    if config.overwrite_cursor then
        vim.opt.guicursor = ''
    end

    if config.cursors and not vim.tbl_isempty(config.cursors) then
        Cursor.set(Cursor.extract_list(config.cursors))
        -- Util.set_cursor(Util.get_static_cursors(config.cursors))
    end

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
