--[[

  Copyright (C) 2017 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  lib/7230.lua
  Created by Masatoshi Teruya on 14/08/02.

--]]

--- assign to local
local strtrim = require('rfcvalid.util').strtrim;
local isToken = require('rfcvalid.2616').isToken;
--- constants
-- https://www.ietf.org/rfc/rfc7230.txt
-- 3.2.  Header Fields
--
--    Each header field consists of a case-insensitive field name followed
--    by a colon (":"), optional leading whitespace, the field value, and
--    optional trailing whitespace.
--
--      header-field   = field-name ":" OWS field-value OWS
--
--      field-name     = token
--      field-value    = *( field-content / obs-fold )
--      field-content  = field-vchar [ 1*( SP / HTAB ) field-vchar ]
--      field-vchar    = VCHAR / obs-text
--      VCHAR          = %x21-7E
--      obs-text       = %x80-FF
--
--      token          = 1*tchar
--      tchar          = "!" / "#" / "$" / "%" / "&" / "'" / "*"
--                     / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
--                     / DIGIT / ALPHA
--                     ; any VCHAR, except delimiters
--
--      obs-fold       = CRLF 1*( SP / HTAB )
--                     ; obsolete line folding
--                     ; see Section 3.2.4
--
local SPHT = '[ \t]';
local INVALID_VCHAR = '[^%w%p]';

--- isFieldValue
-- @param str
-- @return str
local function isFieldValue( str )
    if type( str ) == 'string' and not str:find('[^ \t%w%p]') then
        return strtrim( str );
    end
end


return {
    isFieldName = isToken,
    isFieldValue = isFieldValue
};

