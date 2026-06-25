pcall(require, 'luacov')
local testcase = require('testcase')
local assert = require('assert')
local rfc2616 = require('rfcvalid.2616')

-- separators     = "(" | ")" | "<" | ">" | "@"
--                | "," | ";" | ":" | "\" | <">
--                | "/" | "[" | "]" | "?" | "="
--                | "{" | "}" | SP
local SEPARATORS = [=[ "(),/;:<=>?@[\]{}]=]

local function build_invalid_tokens()
    local invalid = {}
    local HTAB = ('\t'):byte(1)
    local SP = ' '
    for i = 1, #SEPARATORS do
        if SEPARATORS:sub(i, i) ~= SP then
            invalid[SEPARATORS:sub(i, i)] = true
        end
    end
    for i = 0, 0x1f do
        if i ~= HTAB then
            invalid[string.char(i)] = true
        end
    end
    invalid[string.char(0x7f)] = true
    return invalid
end

function testcase.isToken_rejects_separators_and_ctl()
    local invalid = build_invalid_tokens()
    for k in pairs(invalid) do
        assert.is_nil(rfc2616.isToken(k))
    end
end

function testcase.isToken_accepts_valid_tokens()
    local invalid = build_invalid_tokens()
    for c = 0, 0x7f do
        c = string.char(c)
        if not invalid[c] then
            if c == ' ' or c == '\t' then
                assert.equal('', rfc2616.isToken(c) or nil)
            else
                assert.equal(c, rfc2616.isToken(c) or nil)
            end
        end
    end
end
