local Util = require 'cursor.util'

--- @class Cursor.Strategy.Timer
--- @field delay number -- delay in ms
--- @field events? string | string[] -- additional events to trigger a cursor blinking
--- @field overwrite_events? boolean -- overwrite default events

local M = {
    _timer = nil,
    _cursor = nil,
    _delay = nil,
}

local function clear_cursor()
    M._timer = nil
    Util.cursor.del(M._cursor)
end

-- setting this to exported module so that it can be used outside
function M.trigger_cursor_blink()
    if M._timer then
        M._timer:close()
    else
        Util.cursor.set(M._cursor)
    end

    M._timer = vim.defer_fn(clear_cursor, M._delay)
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

    if vim.tbl_count(events) == 0 then
        error 'Cursor.nvim: Expected events array not to be empty'

        return
    end

    Util.autocmd(events, {
        group = Util.group,
        callback = M.trigger_cursor_blink,
    })
end

return M
