local log = require("debug/Log")()
local Input = require("input/Input")

log:SetLevel(log.LogLevel.DEBUG)

local test = {}

function test.Parse1()
    local input = Input()

    local f = function(data)
        log:Info(data)
        assert(data.commandValue == "text with space", "Command value")
        assert(data.a == 1, "a")
        assert(data.boo == "abc", "boo")
        assert(data.c, "c")
    end
    local cmd = input:Accept("command", f):AsString():Mandatory()
    cmd:Option("-a"):AsNumber():Mandatory()
    cmd:Option("--boo"):AsString():Mandatory()
    cmd:Option("--c"):AsBoolean():Mandatory()

    input:Exec("command -a 1 --boo abc --c true 'text with space'")
end

local status, err, _ = xpcall(function()
    test.Parse1()
end, traceback)

if not status then
    system.print(err)
end

unit.exit()