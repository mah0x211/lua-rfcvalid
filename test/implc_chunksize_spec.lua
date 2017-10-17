--[[
    test/implc_chunksize_spec.lua
    lua-rfcvalid
--]]
local chunksize = require('rfcvalid.implc').chunksize
-- separators     = "(" | ")" | "<" | ">" | "@"
--                | "," | ";" | ":" | "\" | <">
--                | "/" | "[" | "]" | "?" | "="
--                | "{" | "}" | SP
local SEPARATORS = [=[ "(),/;:<=>?@[\]{}]=]


describe('rfcvalid.implc.chunksize:', function()
    local msg, consumed, len, ext;


    it('can parse hexadecimal strings', function()
        msg = '1e0f\r\n'
        consumed, len, ext = chunksize( msg )
        assert.are.equal( #msg, consumed )
        assert.are.equal( 0x1e0f, len )
        assert.are.equal( nil, ext )
    end)


    it('can parse a ext-name', function()
        for _, msg in ipairs({
            '1e0f;myext1\r\n',
            '1e0f ;myext1\r\n',
            '1e0f ;\t myext1\r\n',
        }) do
            consumed, len, ext = chunksize( msg )
            assert.are.equal( #msg, consumed )
            assert.are.equal( 0x1e0f, len )
            assert.are.same( { 'myext1' }, ext )
        end
    end)


    it('can parse ext-name and ext-val pair', function()
        for _, msg in ipairs({
            '1e0f;myext1=val1\r\n',
            '1e0f ;myext1=val1\r\n',
            '1e0f ;\t myext1=val1\r\n',
        }) do
            consumed, len, ext = chunksize( msg )
            assert.are.equal( #msg, consumed )
            assert.are.equal( 0x1e0f, len )
            assert.are.same( { myext1 = 'val1' }, ext )
        end
    end)


    it('can parse multiple extensions', function()
        for _, msg in ipairs({
            '1e0f;myext1=val1; myext2; myext3; myext4="  \\ val4 \t "\r\n',
            '1e0f ;myext1  =\tval1;\tmyext2 ;\tmyext3 ; \t  myext4  ="  \\ val4 \t "\r\n',
            '1e0f \t ;   myext1\t=   val1 ; \tmyext2;myext3 ; \t  myext4=\t "  \\ val4 \t "\r\n',
            '1e0f\t ; \tmyext1=val1 ; \tmyext2 ;    \tmyext3 ; \t  myext4=\t "  \\ val4 \t "\r\n',
        }) do
            consumed, len, ext = chunksize( msg )
            assert.are.equal( #msg, consumed )
            assert.are.equal( 0x1e0f, len )
            assert.are.same({
                'myext2',
                'myext3',
                myext1 = 'val1',
                myext4 = '"  \\ val4 \t "'
            }, ext )
        end
    end)


    it('cannot be parsed because the message size not enough', function()
        for _, msg in ipairs({
            '1e0f',
            '1e0f;myext1',
            '1e0f ;myext1',
            '1e0f ;\t myext1',
        }) do
            consumed, len, ext = chunksize( msg )
            assert.are.equal( -1, consumed )
            assert.are.equal( nil, len )
            assert.are.same( nil, ext )
        end
    end)


    it('cannot be parsed because it contains invalid byte sequence', function()
        for _, msg in ipairs({
            '1e0f\r\t',
            '1e0f \r\n',
            '1e0f ; myext1 -',
            '1e0f ; myext1 ; \r\n',
            '1e0f ; myext1 ; myext2 = val2\n',
            '1e0f ; myext1 ; myext2 = val2 \n',
            '1e0f ; myext1 ; myext2 = val2 \r\n',
            '1e0f ; myext1 ; myext2 = val2 ; myext3 = " val3 "\n',
            '1e0f ; myext1 ; myext2 = val2 ; myext3 = " val3 " \r\n',
            '1e0f ; myext1 ; myext2 = val2 ; myext3 = " val3 !"\r\n',
            '1e0f ; myext1 ; myext2 = val2 ; myext3 = " val3 \r"\r\n',
            '1e0f ; myext1 ; myext2 = val2 ; myext3 = " val3 \n"\r\n',
        }) do
            consumed, len, ext = chunksize( msg )
            assert.are.equal( -2, consumed )
            assert.are.equal( nil, len )
            assert.are.same( nil, ext )
        end
    end)
end)
