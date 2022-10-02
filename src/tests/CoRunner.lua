local log = require("debug/Log")()
local co = require("system/CoRunner")(0.01)
local Stopwatch = require("system/Stopwatch")

log:SetLevel(log.LogLevel.DEBUG)

local test = {}
local count = 0
local done = false

function test.CoRunner()
    co:Execute(function()
        log:Info("Test started")
        local stopwatch = Stopwatch.New()
        stopwatch:Start()

        while not done and stopwatch:Elapsed() < 6 do
            log:Info("Not yet", stopwatch:Elapsed())
            count = count + 1
            coroutine.yield()
        end

        log:Info("Test complete")
    end,
        function()
            unit.exit()
        end)

    co:Delay(function()
        done = true
    end, 5)

    co:Delay(function()
        log:Error(false, "Test failed")
        unit.exit()
    end, 5.5)
end

local status, err, _ = xpcall(function()
    test.CoRunner()
end, traceback)

if not status then
    system.print(err)
end
