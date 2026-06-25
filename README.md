# lua-rfcvalid


[![test](https://github.com/mah0x211/lua-rfcvalid/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-rfcvalid/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-rfcvalid/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-rfcvalid)

RFC specification based validation modules.


## Installation

```
luarocks install rfcvalid
```


## Modules

- [`rfcvalid.1035`](#rfcvalid1035---rfc-1035-domain-names) — RFC 1035 domain names
- [`rfcvalid.2616`](#rfcvalid2616---rfc-2616-http11) — RFC 2616 HTTP/1.1 tokens
- [`rfcvalid.6265`](#rfcvalid6265---rfc-6265-cookies) — RFC 6265 cookies
- [`rfcvalid.6749`](#rfcvalid6749---rfc-6749-oauth-20) — RFC 6749 OAuth 2.0
- [`rfcvalid.7230`](#rfcvalid7230---rfc-7230-http11-message-syntax) — RFC 7230 HTTP/1.1 message syntax
- [`rfcvalid.util`](#rfcvalidutil---utilities) — numeric utilities
- [`rfcvalid.implc`](#rfcvalidimplc---c-helpers) — C-level helpers (vchar, tchar, chunksize, etc.)


## `rfcvalid.1035` — RFC 1035 domain names


### ok = isHostname( str )

validates that `str` conforms to a hostname as defined by RFC 1035.

**Parameters**

- `str:string`: hostname candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


## `rfcvalid.2616` — RFC 2616 HTTP/1.1


### ok = isToken( str )

validates that `str` conforms to an HTTP token as defined by RFC 2616.

**Parameters**

- `str:string`: token candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


## `rfcvalid.6265` — RFC 6265 cookies


### ok = isCookieName( str )

validates that `str` conforms to a cookie-name as defined by RFC 6265. Alias of `rfcvalid.2616.isToken`.

**Parameters**

- `str:string`: cookie-name candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


### ok = isCookieValue( str )

validates that `str` conforms to a cookie-value as defined by RFC 6265.

**Parameters**

- `str:string`: cookie-value candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


## `rfcvalid.6749` — RFC 6749 OAuth 2.0


### ok = isScopeToken( str )

validates that `str` conforms to a scope-token (NQCHAR sequence) as defined by RFC 6749.

**Parameters**

- `str:string`: scope-token candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


## `rfcvalid.7230` — RFC 7230 HTTP/1.1 message syntax


### ok = isFieldName( str )

validates that `str` conforms to a field-name as defined by RFC 7230. Alias of `rfcvalid.2616.isToken`.

**Parameters**

- `str:string`: field-name candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


### ok = isFieldValue( str )

validates that `str` conforms to a field-value as defined by RFC 7230.

**Parameters**

- `str:string`: field-value candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


## `rfcvalid.util` — utilities


### ok = isUnsigned( str )

validates that `str` is an unsigned integer.

**Parameters**

- `str:string`: numeric candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


### ok = isUInt( str )

alias of `isUnsigned`.


### ok = isUInt8( str )

validates that `str` is an unsigned 8-bit integer (0–255).

**Parameters**

- `str:string`: numeric candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


### ok = isUInt16( str )

validates that `str` is an unsigned 16-bit integer (0–65535).

**Parameters**

- `str:string`: numeric candidate.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


## `rfcvalid.implc` — C helpers


### ok = isvchar( str )

validates that `str` consists only of VCHAR characters (printable ASCII, `%x21-7E`).

**Parameters**

- `str:string`: input string.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


### ok = istchar( str )

validates that `str` consists only of TCHAR characters as defined by RFC 7230.

**Parameters**

- `str:string`: input string.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


### ok = iscookie( str )

validates that `str` is a valid cookie octet sequence as defined by RFC 6265.

**Parameters**

- `str:string`: input string.

**Returns**

- `ok:string|nil`: returns `str` when valid, `nil` otherwise.


### consumed, len, ext = chunksize( msg )

parses an HTTP chunk-size line as defined by RFC 7230 §4.1.

**Parameters**

- `msg:string`: input buffer that may contain a chunk-size line.

**Returns**

- `consumed:integer`:
  - `>=0`: bytes consumed from `msg` on success.
  - `-1`: input is partial; more bytes are needed.
  - `-2`: input contains an invalid byte sequence.
- `len:integer|nil`: parsed chunk length in bytes.
- `ext:table|nil`: chunk extensions. Array entries hold flag-only names; keyed entries hold `name = value` pairs.


### trimmed = strtrim( str )

trims leading and trailing OWS (optional whitespace) from `str`.

**Parameters**

- `str:string`: input string.

**Returns**

- `trimmed:string`: trimmed string.
