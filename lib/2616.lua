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
  
  lib/2616.lua
  Created by Masatoshi Teruya on 14/12/09.
  
--]]

-- module
local trim = require('util.string').trim;

-- https://www.ietf.org/rfc/rfc2616.txt
-- 2.2 Basic Rules
--
-- CHAR         = 0-127
-- CTLs         = any US-ASCII control character (octets 0 - 31) and DEL (127)
-- token        = 1*<any CHAR except CTLs or separators>
-- separators     = "(" | ")" | "<" | ">" | "@"
--                | "," | ";" | ":" | "\" | <">
--                | "/" | "[" | "]" | "?" | "="
--                | "{" | "}" | SP | HT
local TOKEN = 
    -- ! # $ % & ' * + - .
    '\x21\x23-\x27\x2A-\x2B\x2D\x2E' .. 
    -- 0-9A-Z
    '\x30-\x39\x41-\x5A' ..
    -- ^ _ ` a-z | ~
    '\x5E-\x7A\x7C\x7E';
local INVALID_TOKEN = '[^' .. TOKEN .. ']';


local function isToken( val, toTrim )
    if type( val ) ~= 'string' then
        return nil;
    elseif toTrim == true then
        val = trim( val );
    end
    
    return #val > 0 and not val:find( INVALID_TOKEN ) and val or nil;
end

return {
    isToken = isToken
};

