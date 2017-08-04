--[[

  Copyright (C) 2014 Masatoshi Teruya

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

  lib/6265.lua
  Created by Masatoshi Teruya on 14/12/09.

--]]

-- https://www.ietf.org/rfc/rfc6265.txt
-- 4.1.1.  Syntax
--
-- cookie-name  = token (RFC2616)
-- cookie-value = *cookie-octet / ( DQUOTE *cookie-octet DQUOTE )
-- cookie-octet = %x21 / %x23-2B / %x2D-3A / %x3C-5B / %x5D-7E
--                  ; ! # $ % & ' ( ) * + - . / 0-9 : < = > ? @ A-Z [ ] ^ _ `
--                  ; a-z { | } ~
--                  ; US-ASCII characters excluding CTLs,
--                  ; whitespace DQUOTE, comma, semicolon,
--                  ; and backslash
local INVALID_COOKIE_OCTET = "[^%w!#$%%&'()*+./:<=>?@[%]^_`{|}~-]";


--- isCookieValue
-- @param str
-- @return str
local function isCookieValue( str )
    local octet;

    if type( str ) ~= 'string' then
        return nil;
    end

    -- enclosed by double-quotes
    octet = str:match('^"(.*)"$') or str;
    if #octet < 1 then
        return str;
    end

    return not ( octet:find( INVALID_COOKIE_OCTET ) ) and str or nil;
end


return {
    isCookieName = require('rfcvalid.2616').isToken,
    isCookieValue = isCookieValue
};

