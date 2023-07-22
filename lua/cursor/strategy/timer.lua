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

        ---@diagnostic disable-next-line: param-type-mismatch
        vim.list_extend(events, type(config.events) == 'table' and config.events or { config.events })
    elseif not config.overwrite_events then
        events = { 'CursorMoved', 'CursorMovedI' }
    end

    vim.validate {
        events = {
            events,
            function(v)
                if type(v) ~= 'table' then
                    return false, 'expected events to be table'
                end

                return vim.tbl_count(v) > 0, 'expected events table not to be empty'
            end,
        },
    }

    Util.autocmd(events, {
        group = Util.group,
        callback = M.trigger,
    })
end

return M
