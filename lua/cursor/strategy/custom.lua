local Cursor = require 'cursor.cursor'

local M = {
    _initialized = false,
    _triggered = false,
    _cursor = nil,
}

-- noop while not initialized
function M.trigger() end
function M.clear() end

--- @param cursor string
function M:init(cursor)
    self._initialized = true
    self._cursor = cursor

    function M.trigger()
        if M._triggered then
            return
        end

        Cursor.set(cursor)
    end

    function M.clear()
        if not M._triggered then
            return
        end

        Cursor.del(cursor)
    end
end

return M
