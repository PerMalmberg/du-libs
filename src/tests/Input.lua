local log = require("debug/Log")()
local Input = require("input/Input")
local Criteria = require("input/Criteria")
local keys = require("input/Keys")

log:SetLevel(log.LogLevel.DEBUG)

local input = Input()
input:Register(keys.option1, Criteria():LCtrl():LAlt():LShift():OnPress(), function()
    log:Info("CTRL - LALT - LSHIFT + option1 pressed")
end)

input:Register(keys.option2, Criteria():LAlt():OnPress(), function()
    log:Info("option2 pressed")
end)

input:Register(keys.option2, Criteria():LAlt():OnRelease(), function()
    log:Info("option2 released")
end)

input:Register(keys.option3, Criteria():LCtrl():LAlt():OnRepeat(), function()
    log:Info("LALT - LCTRL + option3 repeat")
end)

local status, err, _ = xpcall(function()

end, traceback)

if not status then
    system.print(err)
end