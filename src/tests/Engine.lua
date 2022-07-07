local engine = require("abstraction/Engine")()
local vehicle = require("abstraction/Vehicle")()
local log = require("debug/Log")()

local test = {}

function test.TestEngine()
    system.print("Forward " .. engine:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(vehicle.orientation.Forward()))
    system.print("Right " .. engine:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(vehicle.orientation.Right()))
    system.print("Up " .. engine:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(vehicle.orientation.Up()))
    system.print("Back " .. engine:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(-vehicle.orientation.Forward()))
    system.print("Left " .. engine:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(-vehicle.orientation.Right()))
    system.print("Down " .. engine:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(-vehicle.orientation.Up()))

end

local status, err, _ = xpcall(function()
    test.TestEngine()
end, traceback)

if not status then
    system.print(err)
end