local Util = require 'cursor.util'

local M = {
    _move_events = { 'CursorMoved', 'CursorMovedI' },
    _hold_events = { 'CursorHold', 'CursorHoldI' },
    _autocmd_id = nil,
    _cursor = nil,
}

-- saving it right in the module so that we don't recreate these tables every
-- time when the autocmds are triggered
M._move_opts = {
    group = Util.group,
    callback = function()
        vim.api.nvim_del_autocmd(M._autocmd_id)

        Util.cursor.set(M._cursor)

        M:_watch_hold()
    end,
}

M._hold_opts = {
    group = Util.group,
    callback = function()
        vim.api.nvim_del_autocmd(M._autocmd_id)

        Util.cursor.del(M._cursor)

        M:_watch_movements()
    end,
}

--- @package
--- @private
function M:_watch_movements()
    self._autocmd_id = Util.autocmd(self._move_events, self._move_opts)
end

--- @package
--- @private
function M:_watch_hold()
    self._autocmd_id = Util.autocmd(self._hold_events, self._hold_opts)
end

--- @param cursor string
function M:init(cursor)
    self._cursor = cursor

    M:_watch_movements()
end

return M
