local M = {}

-- TODO: reload it if setup is called more than once
M.setup = require('cursor.config').setup

-- TODO: support reloading
function M.deactivate()
    -- vim.api.nvim_del_augroup_by_id()
end

return M
