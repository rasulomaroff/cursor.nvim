local Cursor = require 'cursor.cursor'

local function get_cursor()
    return table.concat(vim.opt.guicursor:get(), ',')
end

describe('cursor', function()
    local single = 'n:block-Cursor'
    local multiple = 'i:ver25,n:block,v:hor10'

    before_each(function()
        vim.opt.guicursor = ''
        Cursor._replaceable = {}
        Cursor._triggerable = {}
    end)

    it('should set single cursor', function()
        Cursor.set(single)

        assert.are.equal(get_cursor(), single)
    end)

    it('should set multiple cursors', function()
        Cursor.set(single)
        Cursor.set(multiple)

        assert.are.equal(get_cursor(), single .. ',' .. multiple)
    end)

    it('should delete single cursor', function()
        Cursor.set(multiple)

        local multiple_table = vim.split(multiple, ',')

        local first = multiple_table[1]

        local without_first = vim.tbl_filter(function(v)
            return v ~= first
        end, multiple_table)

        local without_first_cursor = table.concat(without_first, ',')

        Cursor.del(first)

        assert.are.equal(get_cursor(), without_first_cursor)
    end)

    it('should delete multiple cursors', function()
        Cursor.set(multiple)

        local multiple_table = vim.split(multiple, ',')

        local first = multiple_table[1]

        local without_first = vim.tbl_filter(function(v)
            return v ~= first
        end, multiple_table)

        local without_first_cursor = table.concat(without_first, ',')

        Cursor.del(without_first_cursor)

        assert.are.equal(get_cursor(), first)
    end)

    it('should get single blink cursor', function()
        Cursor:set_constant_cursors {
            {
                mode = 'i',
                blink = {
                    on = 400,
                    off = 400,
                    wait = 100,
                },
            },
        }

        assert.are.equal(get_cursor(), 'i:blinkwait100-blinkon400-blinkoff400')

        vim.opt.guicursor = ''

        Cursor:set_constant_cursors {
            {
                mode = 'n',
                blink = {
                    on = 300,
                    off = 300,
                    wait = 200,
                },
                shape = 'ver',
                size = 40,
                hl = { 'Test', 'lTest' },
            },
        }

        assert.are.equal(get_cursor(), 'n:ver40-Test/lTest-blinkwait200-blinkon300-blinkoff300')
    end)

    it('should get multiple blink cursors', function()
        Cursor:set_constant_cursors {
            {
                mode = 'i',
                blink = {
                    on = 400,
                    off = 400,
                    wait = 100,
                },
            },
            {
                mode = 'n',
                blink = 200,
            },
        }

        assert.are.equal(get_cursor(), 'i:blinkwait100-blinkon400-blinkoff400,n:blinkwait200-blinkon200-blinkoff200')

        vim.opt.guicursor = ''

        Cursor:set_constant_cursors {
            {
                mode = 'n',
                blink = {
                    on = 300,
                    off = 300,
                    wait = 200,
                },
                shape = 'ver',
                size = 40,
                hl = 'Test',
            },
            {
                mode = 'i',
                blink = 100,
                shape = 'block',
                size = 40,
                hl = 'HL',
            },
        }

        assert.are.equal(
            get_cursor(),
            'n:ver40-Test-blinkwait200-blinkon300-blinkoff300,i:block-HL-blinkwait100-blinkon100-blinkoff100'
        )
    end)

    it('should get single static cursor', function()
        Cursor:set_constant_cursors {
            { mode = 'n', hl = 'Cur', shape = 'block' },
        }

        assert.are.equal(get_cursor(), 'n:block-Cur')

        vim.opt.guicursor = ''

        Cursor:set_constant_cursors {
            { mode = 'a', hl = 'Test', shape = 'ver', size = 40 },
        }

        assert.are.equal(get_cursor(), 'a:ver40-Test')
    end)

    it('should get multiple static cursors', function()
        Cursor:set_constant_cursors {
            { mode = 'n', hl = 'Cur', shape = 'block' },
            { mode = 'i', hl = { 'Cur', 'lCur' }, shape = 'hor', size = 40 },
        }

        assert.are.equal(get_cursor(), 'n:block-Cur,i:hor40-Cur/lCur')
    end)

    it('should remove replaceable cursors while trigger is active and return them back', function()
        local cursors = {
            {
                mode = 'i',
                blink = 100,
                shape = 'block',
                size = 40,
                hl = 'HL',
            },
            { mode = 'n', hl = 'Cur', shape = 'block', replace = true },
            { mode = 'i', hl = { 'Cur', 'lCur' }, shape = 'hor', size = 40, replace = true },
        }

        Cursor:set_constant_cursors(cursors)

        local string_cursors = vim.tbl_map(function(csr)
            return Cursor:stringify(csr)
        end, cursors)

        assert.are.equal(get_cursor(), table.concat(string_cursors, ','))

        Cursor:trigger()

        assert.are.equal(get_cursor(), Cursor:stringify(cursors[1]))

        Cursor:revoke()

        assert.are.equal(get_cursor(), table.concat(string_cursors, ','))
    end)
end)
