local Util = require 'cursor.util'

describe('util', function()
    it('recognizes strategy', function()
        assert.True(Util.has_strategy 'timer')
        assert.True(Util.has_strategy 'event')
        assert.True(Util.has_strategy 'custom')

        assert.False(Util.has_strategy '')
        assert.False(Util.has_strategy 'invalidstring')
        assert.False(Util.has_strategy(nil))
        assert.False(Util.has_strategy(true))
        assert.False(Util.has_strategy(false))
    end)
end)
