--- @class Cursor.Config
--- @field trigger? Cursor.Trigger
--- @field cursors? (Cursor.Cursor | string)[]
--- @field overwrite_cursor? boolean -- clear default cursor

--- @class Cursor.Trigger
--- @field strategy? Cursor.Strategy
--- @field cursors? (Cursor.Cursor | string)[]

--- @class Cursor.Strategy
--- @field type? 'event' | 'timer' | 'custom'
--- @field timer? Cursor.Strategy.Timer

--- @class Cursor.Strategy.Timer
--- @field delay number -- delay in ms
--- @field events? string | string[] -- additional events to trigger a cursor blinking
--- @field overwrite_events? boolean -- overwrite default events

--- @type Cursor.Config
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
            { mode = 'a', blink = { wait = 100, freq = 400 } },
        },
    },
    overwrite_cursor = false,
    cursors = nil,
}
