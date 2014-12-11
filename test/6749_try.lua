local rfc = require('rfcvalid.6749');

-- construct invalid token table
local invalidTokens = {};
-- ctl
for i = 0, 0x1f do
    invalidTokens[string.char(i)] = true;
end

-- scope-token = 1*NQCHAR
-- NQCHAR      = %x21 / %x23-5B / %x5D-7E
local excluding = [=[ "\]=];
for i = 1, #excluding do
    invalidTokens[excluding:sub(i,i)] = true;
end
-- DEL
invalidTokens[string.char(0x7f)] = true;

-- check
for c = 0, 0x7f do
    c = string.char(c);
    if invalidTokens[c] then
        ifNotNil( rfc.isScopeToken( c ) );
    else
        ifNil( rfc.isScopeToken( c ) );
    end
end
ifNotNil( rfc.isScopeToken( '' ) );

