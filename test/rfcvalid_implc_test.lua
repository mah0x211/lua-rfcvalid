require("luacov")
local testcase = require('testcase')
local assert = require('assert')
local chunksize = require('rfcvalid.implc').chunksize

function testcase.chunksize_parses_hexadecimal_size()
    local msg = '1e0f\r\n'
    local consumed, len, ext = chunksize(msg)
    assert.equal(#msg, consumed)
    assert.equal(0x1e0f, len)
    assert.is_nil(ext)
end

function testcase.chunksize_parses_ext_name()
    for _, msg in ipairs({
        '1e0f;myext1\r\n',
        '1e0f ;myext1\r\n',
        '1e0f ;\t myext1\r\n',
    }) do
        local consumed, len, ext = chunksize(msg)
        assert.equal(#msg, consumed)
        assert.equal(0x1e0f, len)
        assert.equal('myext1', ext[1])
    end
end

function testcase.chunksize_parses_ext_name_val_pair()
    for _, msg in ipairs({
        '1e0f;myext1=val1\r\n',
        '1e0f ;myext1=val1\r\n',
        '1e0f ;\t myext1=val1\r\n',
    }) do
        local consumed, len, ext = chunksize(msg)
        assert.equal(#msg, consumed)
        assert.equal(0x1e0f, len)
        assert.equal('val1', ext.myext1)
    end
end

function testcase.chunksize_parses_multiple_extensions()
    for _, msg in ipairs({
        '1e0f;myext1=val1; myext2; myext3; myext4="  \\ val4 \t "\r\n',
        '1e0f ;myext1  =\tval1;\tmyext2 ;\tmyext3 ; \t  myext4  ="  \\ val4 \t "\r\n',
        '1e0f \t ;   myext1\t=   val1 ; \tmyext2;myext3 ; \t  myext4=\t "  \\ val4 \t "\r\n',
        '1e0f\t ; \tmyext1=val1 ; \tmyext2 ;    \tmyext3 ; \t  myext4=\t "  \\ val4 \t "\r\n',
    }) do
        local consumed, len, ext = chunksize(msg)
        assert.equal(#msg, consumed)
        assert.equal(0x1e0f, len)
        assert.equal('myext2', ext[1])
        assert.equal('myext3', ext[2])
        assert.equal('val1', ext.myext1)
        assert.equal('"  \\ val4 \t "', ext.myext4)
    end
end

function testcase.chunksize_returns_partial_on_short_input()
    for _, msg in ipairs({
        '1e0f',
        '1e0f;myext1',
        '1e0f ;myext1',
        '1e0f ;\t myext1',
    }) do
        local consumed, len, ext = chunksize(msg)
        assert.equal(-1, consumed)
        assert.is_nil(len)
        assert.is_nil(ext)
    end
end

function testcase.chunksize_returns_error_on_invalid_byte_sequence()
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
        local consumed, len, ext = chunksize(msg)
        assert.equal(-2, consumed)
        assert.is_nil(len)
        assert.is_nil(ext)
    end
end
