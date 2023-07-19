local Util = require 'cursor.util'
local Cursor = require 'cursor.cursor'

local M = {
    _timer = nil,
    _delay = nil,
}

local function clear()
    M._timer = nil

    Cursor:revoke()
end

-- assigning this to the exported module so that it can be used outside
function M.trigger()
    if M._timer then
        M._timer:close()
    else
        Cursor:trigger()
    end

    M._timer = vim.defer_fn(clear, M._delay)
end

--- @param config Cursor.Strategy.Timer
function M:init(config)
    vim.validate {
        delay = { config.delay, 'n' },
    }

    self._delay = config.delay

    --- @type string[]
    local events

    if config.events then
        events = config.overwrite_events and {} or { 'CursorMoved', 'CursorMovedI' }

        if type(config.events) == 'table' then
            events = vim.tbl_extend('force', events, config.events --[[ @as table<string> ]])
        else
            -- use "extend" here and above, so that if default events passed,
            -- they won't be applied twice
            events = vim.tbl_extend('force', events, { config.events })
        end
    else
        events = { 'CursorMoved', 'CursorMovedI' }
    end

    vim.validate {
        events = {
            events,
            function(v)
                return vim.tbl_count(v) > 0
            end,
            'events not to be empty',
        },
    }

    Util.autocmd(events, {
        group = Util.group,
        callback = M.trigger,
    })
end

return M
