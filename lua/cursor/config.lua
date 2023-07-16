--- @class Cursor.Config
--- @field trigger
--- @field cursors? (Cursor.StaticCursor | string)[]
--- @field blink? Cursor.Strategy
--- @field overwrite_cursor? boolean -- clear default cursor

--- @class Cursor.Trigger
--- @field strategy? Cursor.Strategy
--- @field cursors?

--- @class Cursor.Config.Blink
--- @field strategy? Cursor.Strategy

return {
    trigger = {
        strategy = {
            type = 'event',
            timer = {
                delay = 5000,
                events = nil,
                overwrite_events = false,
            },
        },
        cursors = {
            { mode = 'a', blinkwait = 100, blinkon = 400, blinkoff = 400 },
        },
    },
    overwrite_cursor = false,
    cursors = nil,
}
