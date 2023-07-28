--- @class Cursor.Cursor
--- @field mode string | string[] - You can check possible modes by :h 'guicursor'
--- @field blink? Cursor.Cursor.Blink | number | false
--- @field shape 'hor' | 'ver' | 'block' - stand for horizontal, vertical, and block
--- @field size? number - number from 1 to 100. Only works in GUI.
--- @field hl? string | [string, string]
--- @field replace? boolean - remove this cursor while a trigger is active. default: false

--- @class Cursor.Cursor.Blink
--- @field wait? number
--- @field on? number
--- @field off? number
--- @field default? number - unspecified blink properties will be set to this value

local M = {
    _replaceable = {},
    _triggerable = {},
}

function M:trigger()
    for _, cursor in ipairs(self._triggerable) do
        self.set(cursor)
    end

    for _, cursor in ipairs(self._replaceable) do
        self.del(cursor)
    end
end

function M:revoke()
    for _, cursor in ipairs(self._triggerable) do
        self.del(cursor)
    end

    for _, cursor in ipairs(self._replaceable) do
        self.set(cursor)
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
--- @return string
function M:stringify(cursor)
    vim.validate {
        mode = { cursor.mode, { 's', 't' } },
    }

    --- @type string
    ---@diagnostic disable-next-line: param-type-mismatch
    local cursor_string = (type(cursor.mode) == 'table' and table.concat(cursor.mode, '-') or cursor.mode) .. ':'

    local has_form = false

    if cursor.hl or cursor.size or cursor.shape then
        has_form = true
        cursor_string = cursor_string .. self.stringify_form_part(cursor)
    end

    if cursor.blink ~= nil then
        if has_form then
            cursor_string = cursor_string .. '-'
        end

        cursor_string = cursor_string .. self.stringify_blink_part(cursor.blink)
    elseif not has_form then
        error 'You did not specify nor blink nor a cursor form'
        return ''
    end

    return cursor_string
end

--- @param cursors (Cursor.Cursor | string)[]
function M:set_trigger_cursors(cursors)
    self.iterate(cursors, function(cursor)
        table.insert(M._triggerable, cursor.str)
    end)
end

--- @param cursors (Cursor.Cursor | string)[]
function M:set_constant_cursors(cursors)
    self.iterate(cursors, function(cursor)
        if cursor.tbl and cursor.tbl.replace then
            table.insert(M._replaceable, cursor.str)
        end

        self.set(cursor.str)
    end)
end

--- @param cursors (Cursor.Cursor | string)[]
function M.iterate(cursors, cb)
    for _, cursor in ipairs(cursors) do
        if type(cursor) == 'table' then
            local csr = M:stringify(cursor)

            cb { str = csr, tbl = cursor }
        else
            for _, csr in
                -- split it, because string with multiple cursors can pe passed
                ipairs(vim.split(cursor --[[ @as string ]], ','))
            do
                cb { str = csr }
            end
        end
    end
end

--- @package
--- @private
--- @param cursor Cursor.Cursor
function M.stringify_form_part(cursor)
    vim.validate {
        size = {
            cursor.size,
            { 'n', 'nil' },
            function(s)
                if cursor.shape == 'block' then
                    return true
                end

                return s > 0 and s <= 100
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

    if cursor.shape then
        -- to be honest, there's no sense in doing that, since neovim handles block shape
        -- even if you specify its size (the size just won't be applied), but a more correct way
        -- is just not specifying a size when you set the "block" cursor anyway
        if cursor.shape == 'block' then
            cursor_str = cursor.shape
        else
            cursor_str = cursor.shape .. cursor.size
        end
    end

    if cursor.hl then
        ---@diagnostic disable-next-line: param-type-mismatch
        return cursor_str .. '-' .. (type(cursor.hl) == 'table' and table.concat(cursor.hl, '/') or cursor.hl)
    end

    return cursor_str
end

--- @package
--- @private
--- @param blink Cursor.Cursor.Blink | number | false
function M.stringify_blink_part(blink)
    -- NOTE: it will only apply if blink is false. blink == nil should not come here
    -- because there's a check for nil above in the code.
    if not blink then
        return 'blinkwait0-blinkon0-blinkoff0'
    end

    if type(blink) == 'number' then
        return string.format('blinkwait%s-blinkon%s-blinkoff%s', blink, blink, blink)
    end

    return string.format(
        'blinkwait%s-blinkon%s-blinkoff%s',
        blink.wait or blink.default,
        blink.on or blink.default,
        blink.off or blink.default
    )
end

return M
