require("environment"):Prepare()
local CommandLine = require("commandline/CommandLine")
local cmd = CommandLine.Instance()

local function test(s)
    system:triggerEvent("onInputText", s)
end

describe("Command line tests", function()
    it("Can take a single command without parameters", function()
        local executed = false

        cmd.Accept("test", function(data)
            executed = true
        end)

        test("wrong command")
        assert.is_false(executed)
        test("test")
        assert.is_true(executed)
    end)

    it("Can take a command argument with space as well as the command argument", function()
        local out
        cmd.Accept("with-arg", function(data)
            out = data.commandValue
        end).AsString()
        test("with-arg 'the option'")
        assert.are_equal("the option", out)
    end)

    it("Can take multiple options", function()
        local arg, opt1, opt2

        local c = cmd.Accept("has-options", function(data)
            arg = data.commandValue
            opt1 = data.opt1
            opt2 = data.opt2
        end):AsNumber()

        c.Option("opt1").AsString()
        c.Option("opt2").AsNumber()

        test("has-options abc -opt1 1 -opt2 2")
        assert.is_nil(arg)
        assert.is_nil(opt1)

        test("has-options 1 -opt1 abc -opt2 2")
        assert.are_equal(1, arg)
        assert.are_equal("abc", opt1)
        assert.are_equal(2, opt2)
    end)

    it("Can handle mandatory arguments", function()
        local v
        local c = cmd.Accept("mandatory-arg", function(data)
            v = data.commandValue
        end).AsString().Must()

        test("mandatory-arg")
        assert.is_nil(v)
        test("mandatory-arg 1")
        assert.are_equal("1", v)
    end)

    it("Can handle mandatory options", function()
        local v
        local c = cmd.Accept("mandatory-opt", function(data)
            v = data.mand
        end):AsEmpty()

        c.Option("mand"):Must():AsNumber()
        test("mandatory-opt")
        assert.is_nil(v)
        test("mandatory-opt -mand 1")
        assert.are_equal(1, v)
    end)

    it("Can handle mandatory boolean arguments", function()
        local v

        local c = cmd.Accept("bool", function(data)
            v = data.commandValue
        end).AsBoolean().Must()

        test("bool")
        assert.is_nil(v)
        test("bool true")
        assert.is_true(v)
    end)

    it("Can handle mandatory boolean option", function()
        local v

        local c = cmd.Accept("bool", function(data)
            v = data.opt1
        end)

        c.Option("opt1").AsBoolean().Must()

        test("bool")
        assert.is_nil(v)

        test("bool -opt1")
        assert.is_nil(v)

        test("bool -opt1 false")
        assert.is_false(v)
        test("bool -opt1 true")
        assert.is_true(v)
    end)

    it("Can handle more complex commands", function()
        local d

        local verify = function()
            assert.are_equal("text with space", d.commandValue)
            assert.are_equal(1, d.a)
            assert.are_equal("abc", d.boo)
            assert.are_equal(true, d.c)
            assert.are_equal(123.456, d.f)
            assert.are_equal(678, d.default)
            assert.are_equal(-123.456, d.negative)
        end

        local c = cmd.Accept("complex", function(data)
            d = data
        end).AsString():Must()
        c.Option("-a").AsNumber().Must()
        c.Option("--boo").AsString().Must()
        c.Option("--c").AsBoolean().Must()
        c.Option("-f").AsNumber().Must()
        c.Option("-default").AsNumber().Must().Default(678)
        c.Option("-negative").AsNumber().Must()


        test("complex -a 1 --boo abc --c true 'text with space' -f 123.456 -negative -123.456")
        verify()
        d = nil
        test("complex -f 123.456 \"text with space\" -a 1 --boo abc --c true -negative -123.456")
        verify()
    end)

    it("Can handle empty boolean option", function()
        local called = false
        local value = nil

        local e = cmd.Accept("empty-boolean", function(data)
            called = true
            value = data.empty
        end).AsEmpty()
        local opt = e.Option("empty")
        opt.AsBoolean().AsEmptyBoolean()

        test("empty-boolean -empty")
        assert.is_true(called)
        assert.is_true(value)
    end)

    it("Can handle missing empty boolean option", function()
        local called = false
        local value = nil

        local e = cmd.Accept("abscent-empty-boolean", function(data)
            called = true
            value = data.empty
        end).AsEmpty()
        local opt = e.Option("empty")
        opt.AsEmptyBoolean()

        test("abscent-empty-boolean")
        assert.is_true(called)
        assert.is_false(value)
    end)

    it("Can handle extra text", function()
        local called = false

        local e = cmd.Accept("empty-boolean-with-extra-text", function(data)
            called = true
        end).AsEmpty()
        local opt = e.Option("empty")
        opt.AsBoolean().AsEmptyBoolean()

        test("empty-boolean-with-extra-text -empty extra text")
        assert.is_false(called)
    end)
end)
