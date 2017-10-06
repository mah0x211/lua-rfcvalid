/*
 *  Copyright (C) 2017 Masatoshi Teruya
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to
 *  deal in the Software without restriction, including without limitation the
 *  rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 *
 *  src/implc.c
 *  lua-rfcvalid
 *  Created by Masatoshi Teruya on 17/10/06.
 *
 */
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
// lua
#include <lua.h>
#include <lauxlib.h>


/**
 * RFC 7230
 * 3.2.  Header Fields
 * https://tools.ietf.org/html/rfc7230#section-3.2
 *
 * OWS            = *( SP / HTAB )
 *                   ; optional whitespace
 * RWS            = 1*( SP / HTAB )
 *                  ; required whitespace
 * BWS            = OWS
 *                  ; "bad" whitespace
 *
 * header-field   = field-name ":" OWS field-value OWS
 *
 * field-name     = token
 *
 * 3.2.6.  Field Value Components
 * https://tools.ietf.org/html/rfc7230#section-3.2.6
 *
 * token          = 1*tchar
 * tchar          = "!" / "#" / "$" / "%" / "&" / "'" / "*"
 *                / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
 *                / DIGIT / ALPHA
 *                ; any VCHAR, except delimiters
 *
 * VCHAR          = %x21-7E
 * delimiters     = "(),/:;<=>?@[\]{}
 *
 */
static const unsigned char TCHAR[256] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
//       "                            (  )            ,            /
    '!', 0, '#', '$', '%', '&', '\'', 0, 0, '*', '+', 0, '-', '.', 0,
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
//  :  ;  <  =  >  ?  @
    0, 0, 0, 0, 0, 0, 0,
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
//  [  \  ]
    0, 0, 0, '^', '_', '`',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
//  {       }
    0, '|', 0, '~'
};


/**
 * RFC 7230
 * 3.1.2.  Status Line
 * https://tools.ietf.org/html/rfc7230#section-3.1.2
 *
 * reason-phrase  = *( HTAB / SP / VCHAR / obs-text )
 *
 * VCHAR          = %x21-7E
 * obs-text       = %x80-FF
 *
 * RFC 7230
 * 3.2.  Header Fields
 * https://tools.ietf.org/html/rfc7230#section-3.2
 *
 * field-value    = *( field-content / obs-fold )
 * field-content  = field-vchar [ 1*( SP / HTAB ) field-vchar ]
 * field-vchar    = VCHAR / obs-text
 *
 * VCHAR          = %x21-7E
 * obs-text       = %x80-FF
 * obs-fold       = CRLF 1*( SP / HTAB )
 *                  ; obsolete line folding
 *                  ; see https://tools.ietf.org/html/rfc7230#section-3.2.4
 */
static const unsigned char VCHAR[256] = {
//                             HTAB
    0, 0, 0, 0, 0, 0, 0, 0, 0, '\t', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
//  %x20-7E
    ' ', '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.',
    '/',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ':', ';', '<', '=', '>', '?', '@',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    '[', '\\', ']', '^', '_', '`',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '{', '|', '}', '~'
};


//
// https://www.ietf.org/rfc/rfc6265.txt
// 4.1.1.  Syntax
//
// cookie-name  = token (RFC2616)
// cookie-value = *cookie-octet / ( DQUOTE *cookie-octet DQUOTE )
// cookie-octet = %x21 / %x23-2B / %x2D-3A / %x3C-5B / %x5D-7E
//                  ; ! # $ % & ' ( ) * + - . / 0-9 : < = > ? @ A-Z [ ] ^ _ `
//                  ; a-z { | } ~
//                  ; US-ASCII characters excluding CTLs,
//                  ; whitespace DQUOTE, comma, semicolon,
//
static const unsigned char COOKIE_OCTET[256] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0,
//  0x21
    '!',
//  0x22
    0,
//  0x23-2B
    '#', '$', '%', '&', '\'', '(', ')', '*', '+',
//  0x2C
    0,
//  0x2D-3A
    '-', '.', '/', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':',
//  0x3B
    0,
//  0x3C-5B
    '<', '=', '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
    'Z', '[',
//  0x5C
    0,
//  0x5D-7E
    ']', '^', '_', '`',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '{', '|', '}', '~'
};


static inline const char *checklstrtrim( lua_State *L, int idx, size_t *len )
{
    const char *str = luaL_checklstring( L, idx, len );
    const char *head = NULL;
    size_t k = *len;
    size_t i = 0;

    // skip head SP = 0x20, HT = 0x9
    for(; i < k; i++ )
    {
        if( str[i] == 0x20 || str[i] == 0x9 ){
            continue;
        }
        break;
    }
    head = str + i;

    // skip tail SP = 0x20, HT = 0x9
    for(; k > i; k-- )
    {
        if( str[k-1] == 0x20 || str[k-1] == 0x9 ){
            continue;
        }
        break;
    }

    k = k - i;
    if( k != *len ){
        *len = k;
        lua_pushlstring( L, head, k );
        lua_replace( L, idx );
    }

    return head;
}


static int strtrim_lua( lua_State *L )
{
    size_t len = 0;

    lua_settop( L, 1 );
    checklstrtrim( L, 1, &len );

    return 1;
}


static int iscookie_lua( lua_State *L )
{
    size_t len = 0;
    uint8_t *str = (uint8_t*)luaL_checklstring( L, 1, &len );
    size_t i = 0;

    // found DQUOTE at head
    if( str[0] == '"' )
    {
        // not found DQUOTE at tail
        if( len == 1 || str[len - 1] != '"' ){
            return 0;
        }
        // skip head and tail
        i++;
        len--;
    }

    for(; i < len; i++ )
    {
        if( !COOKIE_OCTET[str[i]] ){
            return 0;
        }
    }

    return 1;
}


static int istchar_lua( lua_State *L )
{
    size_t len = 0;
    uint8_t *str = (uint8_t*)luaL_checklstring( L, 1, &len );
    size_t i = 0;

    for(; i < len; i++ )
    {

        if( !TCHAR[str[i]] ){
            return 0;
        }
    }

    return 1;
}


static int isvchar_lua( lua_State *L )
{
    size_t len = 0;
    uint8_t *str = (uint8_t*)checklstrtrim( L, 1, &len );

    if( len )
    {
        size_t i = 0;

        for(; i < len; i++ )
        {
            if( !VCHAR[str[i]] ){
                return 0;
            }
        }
    }

    return 1;
}


LUALIB_API int luaopen_rfcvalid_implc( lua_State *L )
{
    struct luaL_Reg funcs[] = {
        { "isvchar", isvchar_lua },
        { "istchar", istchar_lua },
        { "iscookie", iscookie_lua },
        { "strtrim", strtrim_lua },
        { NULL, NULL }
    };
    struct luaL_Reg *ptr = funcs;

    lua_newtable( L );
    while( ptr->name ){
        lua_pushstring( L, ptr->name );
        lua_pushcfunction( L, ptr->func );
        lua_rawset( L, -3 );
        ptr++;
    }

    return 1;
}


