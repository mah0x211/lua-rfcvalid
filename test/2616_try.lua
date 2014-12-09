local rfc2616 = require('rfcvalid.2616');

-- construct invalid token table
local invalidTokens = {};
-- ctl
for i = 0, 0x1f do
    invalidTokens[string.char(i)] = true;
end

-- separators     = "(" | ")" | "<" | ">" | "@"
--                | "," | ";" | ":" | "\" | <">
--                | "/" | "[" | "]" | "?" | "="
--                | "{" | "}" | SP
local separators = [=[ "(),/;:<=>?@[\]{}]=];
for i = 1, #separators do
    invalidTokens[separators:sub(i,i)] = true;
end
-- DEL
invalidTokens[string.char(0x7f)] = true;

-- check
for c = 0, 0x7f do
    c = string.char(c);
    if invalidTokens[c] then
        ifNotNil( rfc2616.isToken( c ) );
        ifNotNil( rfc2616.isToken( c, true ) );
    else
        ifNil( rfc2616.isToken( c ) );
        ifNil( rfc2616.isToken( c, true ) );
    end
end

