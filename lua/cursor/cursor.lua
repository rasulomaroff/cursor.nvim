--- @class Cursor.Cursor
--- @field mode string | string[] - You can check possible modes by :h 'guicursor'
--- @field blink? Cursor.Cursor.Blink | number | false
--- @field shape 'hor' | 'ver' | 'block' - stand for horizontal, vertical, and block
--- @field size? number - string or number from 1 to 100. Only works in GUI.
--- @field hl? string | [string, string]
--- @field replace? boolean - remove this cursor while a trigger is active. default: false

--- @class Cursor.Cursor.Blink
--- @field wait? number
--- @field on? number
--- @field off? number
--- @field freq? number - unspecified properties will be equal to this

local M = {
    _replaceable = {},
    _triggerable = {},
}

function M:trigger()
    for _, cursor in ipairs(self._triggerable) do
        self.set(cursor)
    end

    for _, cursor in ipairs(self._replaceable) do
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.opt.guicursor:remove(cursor)
    end
end

function M:revoke()
    for _, cursor in ipairs(self._triggerable) do
        self.del(cursor)
    end

    for _, cursor in ipairs(self._replaceable) do
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.opt.guicursor:append(cursor)
    end
end

--- @param cursor string
function M.set(cursor)
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.opt.guicursor:append(cursor)
end

--- @param cursor string
function M.del(cursor)
    -- neovim cannot delete several cursors separated with a comma for some reason
    -- but can append them
    local cursors = vim.split(cursor, ',')

    for _, c in ipairs(cursors) do
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.opt.guicursor:remove(c)
    end
end

--- @param cursor Cursor.Cursor
--- @param triggerable? boolean
--- @return string
function M.extract(cursor, triggerable)
    vim.validate {
        mode = { cursor.mode, { 's', 't' } },
    }

    --- @type string
    local cursor_string

    if type(cursor.mode) == 'table' then
        cursor_string = table.concat(cursor.mode --[[ @as table<string> ]], '-') .. ':'
    else
        cursor_string = cursor.mode .. ':'
    end

    local has_form = false

    if cursor.hl or cursor.size or cursor.shape then
        has_form = true
        cursor_string = cursor_string .. M.extract_form(cursor)
    end

    if cursor.blink ~= nil then
        if has_form then
            cursor_string = cursor_string .. '-'
        end

        cursor_string = cursor_string .. M.extract_blink(cursor.blink)
    end

    if has_form and cursor.replace then
        table.insert(M._replaceable, cursor_string)
    end

    if triggerable then
        table.insert(M._triggerable, cursor_string)
    end

    return cursor_string
end

--- @param cursors Cursor.Cursor[]
--- @param triggerable? boolean
--- @return string
function M.extract_list(cursors, triggerable)
    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local cursor_str = type(cursors[1]) == 'table' and M.extract(cursors[1], triggerable) or cursors[1]

    local len = vim.tbl_count(cursors)

    if len == 1 then
        return cursor_str
    else
        for i = 2, len, 1 do
            if type(cursors[i]) == 'table' then
                cursor_str = cursor_str .. ',' .. M.extract(cursors[i], triggerable)
            else
                cursor_str = cursor_str .. ',' .. cursors[i]
            end
        end

        return cursor_str
    end
end

--- @package
--- @private
--- @param cursor Cursor.Cursor
function M.extract_form(cursor)
    vim.validate {
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
                if not cursor.size then
                    return true
                end

                return s == 'ver' or s == 'hor' or s == 'block'
            end,
            '\'ver\' or \'hor\' or \'block\'',
        },
        hl = {
            cursor.hl,
            { 's', 't', 'nil' },
            function(v)
                if type(v) == 'table' then
                    return not vim.tbl_isempty(v)
                elseif type(v) == 'string' then
                    return string.len(v) > 0
                else
                    return false
                end
            end,
            'it not to be empty',
        },
    }

    local cursor_str = ''

    -- to be honest, there's no sense in doing that, since neovim handles block shape
    -- even if you specify its size (it just won't be applied), but a more correct way
    -- is just not specifying a size when you set the "block" cursor anyway
    if cursor.shape then
        if cursor.shape == 'block' then
            cursor_str = cursor.shape
        else
            cursor_str = cursor.shape .. cursor.size
        end
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

--- @package
--- @private
--- @param blink Cursor.Cursor.Blink | number | false
function M.extract_blink(blink)
    if not blink then
        return 'blinkwait0-blinkon0-blinkoff0'
    end

    if type(blink) == 'number' then
        return string.format('blinkwait%s-blinkon%s-blinkoff%s', blink, blink, blink)
    end

    return string.format(
        'blinkwait%s-blinkon%s-blinkoff%s',
        blink.wait or blink.freq,
        blink.on or blink.freq,
        blink.off or blink.freq
    )
end

return M