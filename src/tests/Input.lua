local log = require("debug/Log")()
local Input = require("input/Input")

log:SetLevel(log.LogLevel.DEBUG)

local test = {}

local input = Input()

function test.Input()

end

local status, err, _ = xpcall(function()

end, traceback)

if not status then
    system.print(err)
end