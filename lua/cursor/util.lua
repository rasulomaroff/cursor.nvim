local M = {}

M.group = vim.api.nvim_create_augroup('CommuNVIM-cursor', { clear = true })

function M.autocmd(event, opts)
    return vim.api.nvim_create_autocmd(event, opts)
end

---@param strategy any
---@return boolean
function M.is_strategy(strategy)
    return strategy == 'event' or strategy == 'timer' or strategy == 'custom'
end

return M
