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

  lib/6749.lua
  Created by Masatoshi Teruya on 14/12/11.

--]]

--
-- https://www.ietf.org/rfc/rfc6749.txt
-- Appendix A.  Augmented Backus-Naur Form (ABNF) Syntax
--
-- NQCHAR     = %x21 / %x23-5B / %x5D-7E
--
local NQCHAR = '\x21\x23-\x5B\x5D\x5E-\x7E';
local INVALID_NQCHAR = '[^' .. NQCHAR:gsub( '[%]]', '%%%1' ) .. ']';

--
-- A.4.  "scope" Syntax
-- scope-token = 1*NQCHAR
--
local function isScopeToken( val )
    if type( val ) ~= 'string' or #val < 1 then
        return nil;
    end

    return not val:find( INVALID_NQCHAR ) and val or nil;
end


return {
    isScopeToken = isScopeToken
};

