describe('config', function()
    -- NOTE: keep this test on the top so that it has default cursor
    -- in other case our property will clear it
    it('should not overwrite a cursor', function()
        local current_cursor = table.concat(vim.opt.guicursor:get(), ',')

        local cursor = require 'cursor'

        cursor.setup {
            overwrite_cursor = false,
            cursors = {
                { mode = 'a', shape = 'block' },
                { mode = 'v', shape = 'ver', size = 25 },
            },
        }

        assert.are.equal(current_cursor .. ',a:block,v:ver25', table.concat(vim.opt.guicursor:get(), ','))
    end)

    it('should overwrite a cursor', function()
        local cursor = require 'cursor'

        cursor.setup {
            overwrite_cursor = true,
            cursors = {
                { mode = 'a', shape = 'block' },
                { mode = 'i', shape = 'ver', size = 25 },
            },
        }

        assert.are.equal('a:block,i:ver25', table.concat(vim.opt.guicursor:get(), ','))
    end)

    it('should apply cursors correctly', function()
        local cursor = require 'cursor'

        cursor.setup {
            cursors = {
                { mode = 'i', blink = 300, shape = 'hor', size = 40, hl = 'Cursor' },
                { mode = 'v', shape = 'block', hl = 'VCursor' },
                { mode = 'n', shape = 'block', hl = 'NCursor' },
            },
            overwrite_cursor = true,
        }

        assert.are.equal(
            'i:hor40-Cursor-blinkwait300-blinkon300-blinkoff300,v:block-VCursor,n:block-NCursor',
            table.concat(vim.opt.guicursor:get(), ',')
        )
    end)
end)
