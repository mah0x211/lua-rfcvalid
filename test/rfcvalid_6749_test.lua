pcall(require, 'luacov')
local testcase = require('testcase')
local assert = require('assert')
local rfc = require('rfcvalid.6749')

local invalidTokens = {}
for i = 0, 0x1f do
    invalidTokens[string.char(i)] = true
end

-- scope-token = 1*NQCHAR
-- NQCHAR      = %x21 / %x23-5B / %x5D-7E
local excluding = [=[ "\]=]
for i = 1, #excluding do
    invalidTokens[excluding:sub(i, i)] = true
end
invalidTokens[string.char(0x7f)] = true

function testcase.isScopeToken_rejects_invalid_bytes()
    for c = 0, 0x7f do
        c = string.char(c)
        if invalidTokens[c] then
            assert.is_nil(rfc.isScopeToken(c))
        end
    end
end

function testcase.isScopeToken_accepts_valid_bytes()
    for c = 0, 0x7f do
        c = string.char(c)
        if not invalidTokens[c] then
            assert.not_nil(rfc.isScopeToken(c))
        end
    end
end

function testcase.isScopeToken_rejects_empty_string()
    assert.is_nil(rfc.isScopeToken(''))
end
