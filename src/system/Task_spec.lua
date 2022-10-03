require("environment"):Prepare()
local Task = require("system/Task")
local taskmanger = require("system/Taskmanager"):Instance()

local function runUpdate(count)
    for i = 1, count do
        system:triggerEvent("onUpdate")
    end
end

local function createTask()
    local t = Task.New("TestTask", function()
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
    it("Can run tasks", function()
        createTask()
        assert.are_equal(1, taskmanger:Count())
        runUpdate(11)
        assert.are_equal(0, taskmanger:Count())
    end)

    it("Can run multiple Then", function()
        local first
        local a
        local b

        local t = Task.New("TestTask", function()
            coroutine.yield()
            first = "first message"
        end):Then(function()
            coroutine.yield()
            a = "A"
        end):Then(function()
            coroutine.yield()
            b = "B"
        end):Then(function()
            coroutine.yield()
            return "last value"
        end)

        assert.are_equal(1, taskmanger:Count())
        runUpdate(8)
        assert.are_equal("first message", first)
        assert.are_equal("A", a)
        assert.are_equal("B", b)
        assert.are_equal("last value", t:Result())
    end)

    it("Can do await", function()
        local result = 0

        -- Only another Task/coroutine can do Await
        Task.New("TestTask", function()
            local t = createTask()
            result = Task.Await(t)
        end)

        runUpdate(13)
        assert.are_equal(55, result)
    end)

    it("Can do await with chained calls", function()
        local result = 0

        Task.New("TestTask", function()
            local t = Task.New("TestTask2", function()
                coroutine.yield()
            end):Then(function()
                coroutine.yield()
                result = 123
            end)
            result = Task.Await(t)
        end)

        runUpdate(5)
        assert.are_equal(123, result)
    end)

    it("Can handle errors", function()
        local errorMsg = ""
        local final = ""
        local shouldBeNil

        Task.New("TestTask", function()
            error("Opsie!")
        end):Then(function()
            shouldBeNil = "this is not nil"
        end):Catch(function(task)
            errorMsg = task:Error()
        end):Finally(function(task)
            final = "the end!"
        end)

        runUpdate(2)

        assert.is_nil(shouldBeNil)
        assert.has_match("Opsie!", errorMsg)
        assert.are_equal("the end!", final)
    end)

    it("Can handle errors in chained calls", function()
        local result = ""
        local errorMsg = ""
        local final = ""

        Task.New("TestTask", function()
            coroutine.yield()
        end):Then(function(task)
            error("Opsie!")
        end):Catch(function(task)
            result = task:Result()
            errorMsg = task:Error()
        end):Finally(function(task)
            final = "the end!"
        end)

        runUpdate(100)

        assert.is_nil(result)
        assert.has_match("Opsie!", errorMsg)
        assert.are_equal("the end!", final)
    end)

    it("Catch not called on success", function()
        local errorMsg = ""
        local final = ""

        Task.New("TestTask", function()
            -- Do nothing
        end):Catch(function(task)
            errorMsg = "should not see me"
        end):Finally(function(task)
            final = "the end!"
        end)

        runUpdate(100)

        assert.are_equal("", errorMsg)
        assert.are_equal("the end!", final)
    end)

    it("Can handle arguments", function()
        local sum = 0
        local t = Task.New("Summizer", function(...)
            local arg1, arg2 = table.unpack({ ... })
            local s = 0
            for i = arg1, arg2 do
                s = s + i
                coroutine.yield()
            end
            sum = s
        end, 5, 10):Then(function(arg1, arg2)
            local s = 0
            for i = arg1, arg2 do
                s = s + i
                coroutine.yield()
            end
            return s
        end, 1, 5)

        runUpdate(20)

        assert.are_equal(45, sum)
        assert.are_equal(15, t:Result())
    end)

end)
