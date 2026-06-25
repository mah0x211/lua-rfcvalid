pcall(require, 'luacov')
local testcase = require('testcase')
local assert = require('assert')
local rfc6265 = require('rfcvalid.6265')

-- construct invalid token table
local invalidTokens = {}
for i = 0, 0x1f do
    invalidTokens[string.char(i)] = true
end

-- cookie-octet = %x21 / %x23-2B / %x2D-3A / %x3C-5B / %x5D-7E
local excluding = [=[ ",;\]=]
for i = 1, #excluding do
    invalidTokens[excluding:sub(i, i)] = true
end
invalidTokens[string.char(0x7f)] = true

function testcase.isCookieValue_rejects_invalid_bytes()
    for c = 0, 0x7f do
        c = string.char(c)
        if invalidTokens[c] then
            if c == ' ' or c == '\t' then
                assert.equal('', rfc6265.isCookieValue(c))
            else
                assert.is_nil(rfc6265.isCookieValue(c))
            end
            assert.is_nil(rfc6265.isCookieValue('"' .. c .. '"'))
        end
    end
end

function testcase.isCookieValue_accepts_valid_bytes()
    for c = 0, 0x7f do
        c = string.char(c)
        if not invalidTokens[c] then
            assert.not_nil(rfc6265.isCookieValue(c))
            assert.not_nil(rfc6265.isCookieValue('"' .. c .. '"'))
        end
    end
end

function testcase.isCookieValue_accepts_empty_and_quoted_empty()
    assert.not_nil(rfc6265.isCookieValue(''))
    assert.not_nil(rfc6265.isCookieValue('""'))
end
