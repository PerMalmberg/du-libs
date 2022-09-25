require("environment"):Prepare()
local Task = require("system/Task")
local taskmanger = require("system/Taskmanager"):Instance()

local function runUpdate(count)
    for i = 1, count do
        unit:triggerEvent("onUpdate")
    end
end

local function createTask()
    local t = Task.New(function()
        local sum = 0

        for i = 1, 10, 1 do
            sum = sum + i
            coroutine.yield()
        end

        return sum
    end)

    return t
end

describe("Task", function()
    it("Can create Task", function()
        createTask()

        assert.are_equal(1, taskmanger:Count())
    end)

    it("Can run tasks", function()
        assert.are_equal(1, taskmanger:Count())
        runUpdate(100)
        assert.are_equal(0, taskmanger:Count())
    end)

    it("Can do await", function()
        local result = 111

        Task.New(function()
            local t = createTask()
            result = Task.Await(t)
        end)

        runUpdate(100)
        assert.are_equal(55, result)
    end)
end)
