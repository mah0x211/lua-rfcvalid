local rfc6265 = require('rfcvalid.6265');

-- construct invalid token table
local invalidTokens = {};
-- ctl
for i = 0, 0x1f do
    invalidTokens[string.char(i)] = true;
end

-- cookie-octet = %x21 / %x23-2B / %x2D-3A / %x3C-5B / %x5D-7E
--                  ; US-ASCII characters excluding CTLs,
--                  ; whitespace DQUOTE, comma, semicolon,
--                  ; and backslash
local excluding = [=[ ",;\]=];
for i = 1, #excluding do
    invalidTokens[excluding:sub(i,i)] = true;
end
-- DEL
invalidTokens[string.char(0x7f)] = true;

-- check
for c = 0, 0x7f do
    c = string.char(c);
    if invalidTokens[c] then
        ifNotNil( rfc6265.isCookieValue( c ) );
    else
        ifNil( rfc6265.isCookieValue( c ) );
    end
end

