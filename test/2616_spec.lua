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
        local HTAB = ('\t'):byte(1)
        local SP = ' '

        for i = 1, #SEPARATORS do
            -- ignore SP
            if SEPARATORS:sub(i,i) ~= SP then
                invalidTokens[SEPARATORS:sub(i,i)] = true
            end
        end

        -- ctl characters
        for i = 0, 0x1f do
            -- ignore HTAB
            if i ~= HTAB then
                invalidTokens[string.char(i)] = true
            end
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
                    if c == ' ' or c == '\t' then
                        assert.are.equal( '', rfc2616.isToken( c ) or nil )
                    else
                        assert.are.equal( c, rfc2616.isToken( c ) or nil )
                    end
                end
            end
        end)
    end)
end)
