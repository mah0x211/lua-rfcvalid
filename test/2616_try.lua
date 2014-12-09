local trim = require('util.string').trim;
local rfc2616 = require('rfcvalid.2616');

-- construct invalid token table
local invalidTokens = {};
-- ctl
for i = 0, 0x1f do
    invalidTokens[string.char(i)] = false;
end

-- separators     = "(" | ")" | "<" | ">" | "@"
--                | "," | ";" | ":" | "\" | <">
--                | "/" | "[" | "]" | "?" | "="
--                | "{" | "}" | SP
local separators = [=[ "(),/;:<=>?@[\]{}]=];
for i = 1, #separators do
    invalidTokens[separators:sub(i,i)] = false;
end
-- DEL
invalidTokens[string.char(0x7f)] = false;

-- check
for c = 0, 0x7f do
    c = string.char(c);
    if invalidTokens[c] == false then
        ifTrue( rfc2616.isToken( c ) );
    else
        ifNotTrue( rfc2616.isToken( c ) );
    end
end

