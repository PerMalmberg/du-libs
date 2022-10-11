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
        end).AsString().Mandatory()

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

        c.Option("mand"):Mandatory():AsNumber()
        test("mandatory-opt")
        assert.is_nil(v)
        test("mandatory-opt -mand 1")
        assert.are_equal(1, v)
    end)

    it("Can handle boolean arguments", function()
        local v

        local c = cmd.Accept("bool", function(data)
            v = data.commandValue
        end).AsBoolean().Mandatory()

        test("bool")
        assert.is_nil(v)
        test("bool true")
        assert.is_true(v)
    end)
end)
