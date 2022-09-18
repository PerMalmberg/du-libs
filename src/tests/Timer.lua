local log = require("debug/Log")()
local timer = require("system/Timer").Instance()

log:SetLevel(log.LogLevel.DEBUG)

local test = {}

function test.Timer()
    timer:Add("a", function()
        log:Info("Timer!")
    end, 1)
end

local status, err, _ = xpcall(function()
    test.Timer()
end, traceback)

if not status then
    system.print(err)
end