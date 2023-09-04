local function get_cursor()
    return table.concat(vim.opt.guicursor:get(), ',')
end

describe('strategy module:', function()
    local augroup

    before_each(function()
        augroup = vim.api.nvim_create_augroup('strategy-test', { clear = true })
        vim.opt.guicursor = ''

        -- creating and filling a buffer
        local buf = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_win_set_buf(0, buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'test', 'line' })

        local Cursor = require 'cursor.cursor'

        Cursor._triggerable = {}
        Cursor._replaceable = {}
    end)

    after_each(function()
        -- clear all test autocmds and cursor.nvim autocmds as well
        vim.api.nvim_del_augroup_by_id(augroup)
        vim.cmd [[ autocmd! cursor.nvim ]]
        augroup = nil

        vim.cmd [[ bd! ]]
    end)

    it('should trigger cursor in N ms', function()
        require('cursor').setup {
            overwrite_cursor = true,
            cursors = {
                {
                    mode = 'a',
                    shape = 'block',
                },
            },
            trigger = {
                strategy = {
                    type = 'timer',
                    timer = {
                        delay = 50,
                    },
                },
                cursors = {
                    {
                        mode = 'a',
                        shape = 'ver',
                        size = 25,
                    },
                },
            },
        }

        local co = coroutine.running()

        assert.are.equal('a:block', get_cursor())

        -- triggering CursorMoved event
        vim.api.nvim_win_set_cursor(0, { 2, 2 })

        vim.schedule(function()
            assert.are.equal('a:block,a:ver25', get_cursor())

            vim.defer_fn(function()
                assert.are.equal('a:block', get_cursor())

                coroutine.resume(co)
            end, 100)
        end)

        coroutine.yield()
    end)

    it('should be triggered on CursorMoved event and get back on CursorHold event', function()
        vim.opt.updatetime = 100
        require('cursor').setup {
            overwrite_cursor = true,
            cursors = {
                {
                    mode = 'a',
                    shape = 'block',
                },
            },
            trigger = {
                strategy = {
                    type = 'event',
                },
                cursors = {
                    {
                        mode = 'a',
                        shape = 'ver',
                        size = 25,
                    },
                },
            },
        }

        local co = coroutine.running()

        assert.are.equal('a:block', get_cursor())

        vim.api.nvim_create_autocmd('CursorMoved', {
            group = augroup,
            callback = function()
                coroutine.resume(co)
            end,
        })

        -- triggering CursorMoved event
        vim.api.nvim_win_set_cursor(0, { 2, 2 })

        coroutine.yield()

        assert.are.equal('a:block,a:ver25', get_cursor())

        local id = vim.api.nvim_create_autocmd('CursorHold', {
            group = augroup,
            callback = function()
                coroutine.resume(co)
            end,
        })

        coroutine.yield()

        assert.are.equal('a:block', get_cursor())

        vim.api.nvim_del_autocmd(id)
    end)

    it('should react on custom events', function()
        require('cursor').setup {
            overwrite_cursor = true,
            cursors = {
                {
                    mode = 'a',
                    shape = 'block',
                },
            },
            trigger = {
                strategy = {
                    type = 'timer',
                    timer = {
                        delay = 1000,
                        events = { 'InsertEnter' },
                    },
                },
                cursors = {
                    {
                        mode = 'a',
                        shape = 'ver',
                        size = 25,
                    },
                },
            },
        }

        local co = coroutine.running()

        assert.are.equal('a:block', get_cursor())

        vim.api.nvim_create_autocmd('InsertEnter', {
            group = augroup,
            callback = function()
                assert.are.equal('a:block,a:ver25', get_cursor())

                coroutine.resume(co)
            end,
        })

        -- Triggering newly added InsertEnter event trigger
        vim.cmd [[ startinsert ]]

        coroutine.yield()
    end)

    it('should error if empty events are passed with overwrite flag', function()
        -- without events array, but with overwrite flag
        assert.error(function()
            require('cursor').setup {
                overwrite_cursor = true,
                cursors = {
                    {
                        mode = 'a',
                        shape = 'block',
                    },
                },
                trigger = {
                    strategy = {
                        type = 'timer',
                        timer = {
                            delay = 1000,
                            overwrite_events = true,
                        },
                    },
                    cursors = {
                        {
                            mode = 'a',
                            shape = 'ver',
                            size = 25,
                        },
                    },
                },
            }
        end)

        -- with empty events array and with overwrite flag
        assert.error(function()
            require('cursor').setup {
                overwrite_cursor = true,
                cursors = {
                    {
                        mode = 'a',
                        shape = 'block',
                    },
                },
                trigger = {
                    strategy = {
                        type = 'timer',
                        timer = {
                            delay = 1000,
                            events = {},
                            overwrite_events = true,
                        },
                    },
                    cursors = {
                        {
                            mode = 'a',
                            shape = 'ver',
                            size = 25,
                        },
                    },
                },
            }
        end)
    end)

    it('should apply and revoke cursors on method calls', function()
        local custom = require 'cursor.strategy.custom'

        require('cursor').setup {
            overwrite_cursor = true,
            trigger = {
                strategy = {
                    type = 'custom',
                },
                cursors = {
                    {
                        mode = 'a',
                        shape = 'block',
                        blink = {
                            on = 500,
                            off = 500,
                            wait = 100,
                        },
                    },
                },
            },
            cursors = {
                { mode = 'a', shape = 'block', replace = true, hl = 'Test' },
            },
        }

        assert.are.equal(get_cursor(), 'a:block-Test')

        custom.trigger()

        assert.are.equal(get_cursor(), 'a:block-blinkwait100-blinkon500-blinkoff500')

        -- ensure there are no sideeffects if calling twice in a row
        custom.trigger()

        assert.are.equal(get_cursor(), 'a:block-blinkwait100-blinkon500-blinkoff500')

        custom.revoke()

        assert.are.equal(get_cursor(), 'a:block-Test')

        -- ensure there are no sideeffects if calling twice in a row
        custom.revoke()

        assert.are.equal(get_cursor(), 'a:block-Test')
    end)
end)
