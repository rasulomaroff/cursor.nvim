local M = {}

M.cursor = {}
M.group = vim.api.nvim_create_augroup('CommuNVIM-cursor', { clear = true })

--- @param cursor string
function M.cursor.set(cursor)
    vim.opt.guicursor:append(cursor)
end

--- @param cursor string
function M.cursor.del(cursor)
    -- neovim cannot delete several cursors separated with a comma for some reason
    local cursors = vim.split(cursor, ',')

    if #cursors > 1 then
        for _, c in ipairs(cursors) do
            vim.opt.guicursor:remove(c)
        end
    else
        vim.opt.guicursor:remove(cursor)
    end
end

function M.autocmd(event, opts)
    return vim.api.nvim_create_autocmd(event, opts)
end

--- @param cursor Cursor.StaticCursor
--- @return string cursor string that can be passed in vim.opt.guicursor
local function extract_static_cursor(cursor)
    vim.validate {
        mode = { cursor.mode, { 's', 't' } },
        size = {
            cursor.size,
            { 's', 'n', 'nil' },
            function(s)
                if cursor.shape == 'block' then
                    return true
                end

                local size = tonumber(s)

                return size > 0 and size <= 100
            end,
            'it to be between 1 and 100',
        },
        shape = {
            cursor.shape,
            function(s)
                return s == 'ver' or s == 'hor' or s == 'block'
            end,
            '\'ver\' or \'hor\' or \'block\'',
        },
        hl = { cursor.hl, { 't', 's' }, true },
    }

    if type(cursor.mode) == 'table' then
        cursor.mode = table.concat(cursor.mode --[[ @as table<string> ]], '-')
    end

    local cursor_str

    -- to be honest, there's no sense in doing that, since neovim handles block shape
    -- even if you specify its size (it just won't be applied), but a more correct way
    -- is just not to specify a size when you set the "block" cursor anyway
    if cursor.shape == 'block' then
        cursor_str = string.format('%s:%s', cursor.mode, cursor.shape)
    else
        cursor_str = string.format('%s:%s%s', cursor.mode, cursor.shape, cursor.size)
    end

    if cursor.hl then
        if type(cursor.hl) == 'table' then
            return cursor_str .. '-' .. table.concat(cursor.hl --[[ @as table<string> ]], '/')
        else
            return cursor_str .. '-' .. cursor.hl
        end
    else
        return cursor_str
    end
end

--- @param cursor Cursor.BlinkCursor
--- @return string cursor string that can be passed in vim.opt.guicursor
local function extract_blink_cursor(cursor)
    vim.validate {
        mode = { cursor.mode, { 's', 't' } },
        blinkwait = { cursor.blinkwait, { 'n', 's' } },
        blinkon = { cursor.blinkon, { 'n', 's' } },
        blinkoff = { cursor.blinkoff, { 'n', 's' } },
    }

    if cursor.hl or cursor.size or cursor.shape then
        local cursor_string = extract_static_cursor(cursor --[[ @as Cursor.StaticCursor ]])

        return string.format(
            '%s-blinkwait%s-blinkon%s-blinkoff%s',
            cursor_string,
            cursor.blinkwait,
            cursor.blinkon,
            cursor.blinkoff
        )
    end

    if type(cursor.mode) == 'table' then
        cursor.mode = table.concat(cursor.mode --[[ @as table<string> ]], '-')
    end

    return string.format(
        '%s:blinkwait%s-blinkon%s-blinkoff%s',
        cursor.mode,
        cursor.blinkwait,
        cursor.blinkon,
        cursor.blinkoff
    )
end

--- @param cursors (Cursor.BlinkCursor | Cursor.StaticCursor | string)[]
--- @param cursors_type 'static' | 'blink'
--- @return string cursors: string of cursors that can be passed in vim.opt.guicursor
local function get_cursors(cursors, cursors_type)
    local extractor = cursors_type == 'static' and extract_static_cursor or extract_blink_cursor

    local cursor_str = type(cursors[1]) == 'table'
            and extractor(cursors[1] --[[ @as Cursor.BlinkCursor | Cursor.StaticCursor]])
        or cursors[1] --[[ @as string ]]

    local len = vim.tbl_count(cursors)

    if len == 1 then
        return cursor_str
    else
        for i = 2, len, 1 do
            if type(cursors[i]) == 'table' then
                cursor_str = cursor_str
                    .. ','
                    .. extractor(cursors[i] --[[ @as Cursor.BlinkCursor | Cursor.StaticCursor ]])
            else
                cursor_str = cursor_str .. ',' .. cursors[i]
            end
        end

        return cursor_str
    end
end

--- @param cursors (Cursor.BlinkCursor | string)[]
--- @return string cursors: string of cursors that can be passed in vim.opt.guicursor
function M.get_blink_cursors(cursors)
    return get_cursors(cursors, 'blink')
end

--- @param cursors (Cursor.StaticCursor | string)[]
--- @return string cursors: string of cursors that can be passed in vim.opt.guicursor
function M.get_static_cursors(cursors)
    return get_cursors(cursors, 'static')
end

return M
