require("environment"):Prepare()
local CoRunner = require("system/CoRunner")

local function runTicks()
    for i = 1, 1000, 1 do
        unit:triggerEvent("onTimer", "CoRunner0")
    end
end

describe("CoRunner", function()
    local co ---@type CoRunner

    setup(function()
        co = CoRunner:New()
    end)

    teardown(function()
        co:Terminate()
    end)

    it("Can run things in parallell", function()
        local res = ""
        local res2 = ""

        co:Execute(function()
            coroutine.yield()
            res = res .. "-"
            coroutine.yield()
        end, function()
            coroutine.yield()
            coroutine.yield()
            res = res .. "|"
        end)

        co:Execute(function()
            res2 = res2 .. "A"
            coroutine.yield()
            res2 = res2 .. "A"
            coroutine.yield()
            res2 = res2 .. "A"
        end, function()
            res2 = res2 .. "B"
        end)

        runTicks()
        assert.are_equal("-|", res)
        assert.are_equal("AAAB", res2)
    end)

    it("Can delay", function()
        local start = system.getUtcTime()
        local stop = 0

        co:Delay(function()
            stop = system.getUtcTime()
        end, 1)

        while stop == 0 do
            runTicks()
        end

        local diff = stop - start

        assert.is_true(diff >= 1 and diff < 1.1)
    end)
end)
