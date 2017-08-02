--[[
    test/2616_spec.lua
    lua-rfcvalid
--]]
local rfc2616 = require('rfcvalid.2616')
-- separators     = "(" | ")" | "<" | ">" | "@"
--                | "," | ";" | ":" | "\" | <">
--                | "/" | "[" | "]" | "?" | "="
--                | "{" | "}" | SP
local SEPARATORS = [=[ "(),/;:<=>?@[\]{}]=]


describe('rfcvalid.2616:', function()
    local invalidTokens = {}

    -- construct invalid token table
    setup(function()
        for i = 1, #SEPARATORS do
            invalidTokens[SEPARATORS:sub(i,i)] = true
        end

        -- ctl characters
        for i = 0, 0x1f do
            invalidTokens[string.char(i)] = true
        end
        -- DEL
        invalidTokens[string.char(0x7f)] = true
    end)


    describe('test a isToken -', function()
        it('must be return nil', function()
            for k in pairs( invalidTokens ) do
                assert.is_nil( rfc2616.isToken( k ) )
            end
        end)

        it('must be return not nil', function()
            for c = 0, 0x7f do
                c = string.char(c)
                if not invalidTokens[c] then
                    assert.are.equal( c, rfc2616.isToken( c ) )
                end
            end
        end)
    end)
end)
