local log = require("debug/Log")()
local CommandLine = require("commandline/CommandLine")

log:SetLevel(log.LogLevel.DEBUG)

local test = {}

function test.Parse1()
    local input = CommandLine()

    local f = function(data)
        log:Info(data)
        assert(data.commandValue == "text with space", "Command value")
        assert(data.a == 1, "a")
        assert(data.boo == "abc", "boo")
        assert(data.c, "c")
        assert(data.f == 123.456)
        assert(data.default == 678)
    end

    local cmd = input:Accept("command", f):AsString():Mandatory()
    cmd:Option("-a"):AsNumber():Mandatory()
    cmd:Option("--boo"):AsString():Mandatory()
    cmd:Option("--c"):AsBoolean():Mandatory()
    cmd:Option("-f"):AsNumber():Mandatory()
    cmd:Option("-default"):AsNumber():Mandatory():Default(678)

    input:Exec("command -a 1 --boo abc --c true 'text with space' -f 123.456")
    input:Exec("command -f 123.456 'text with space' -a 1 --boo abc --c true")
end

local status, err, _ = xpcall(function()
    test.Parse1()
end, traceback)

if not status then
    system.print(err)
end

unit.exit()