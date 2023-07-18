local Util = require 'cursor.util'
local Cursor = require 'cursor.cursor'

local M = {
    _timer = nil,
    _cursor = nil,
    _delay = nil,
}

local function clear()
    M._timer = nil

    Cursor.del(M._cursor, true)
end

-- setting this to exported module so that it can be used outside
function M.trigger()
    if M._timer then
        M._timer:close()
    else
        Cursor.set(M._cursor, true)
    end

    M._timer = vim.defer_fn(clear, M._delay)
end

--- @param cursor string
--- @param config Cursor.Strategy.Timer
function M:init(cursor, config)
    self._cursor = cursor
    self._delay = config.delay

    --- @type string[]
    local events

    if config.events then
        if config.overwrite_events then
            events = {}
        else
            events = { 'CursorMoved', 'CursorMovedI' }
        end

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

    -- if vim.tbl_count(events) == 0 then
    --     error 'Cursor.nvim: Expected events array not to be empty'
    --
    --     return
    -- end

    Util.autocmd(events, {
        group = Util.group,
        callback = M.trigger,
    })
end

return M
