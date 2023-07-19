local Cursor = require 'cursor.cursor'

local M = {
    _triggered = false,
}

-- noop while not initialized
function M.trigger() end
function M.clear() end

function M:init()
    function M.trigger()
        if M._triggered then
            return
        end

        self._triggered = true
        Cursor:trigger()
    end

    function M.clear()
        if not M._triggered then
            return
        end

        self._triggered = false
        Cursor:revoke()
    end
end

return M
