local timer = require("system/Timer").Instance()
local Stopwatch = require("system/Stopwatch")

local runner = {}
runner.__index = runner

local function newRunner(func, callback)
    local runnerFunction = function()
        local status, ret = xpcall(func, traceback)
        if not status then
            system.print(ret)
        end
    end

    local o = {
        co = coroutine.create(runnerFunction),
        callback = callback
    }
    return setmetatable(o, runner)
end

function runner:Run()
    coroutine.resume(self.co)

    local done = coroutine.status(self.co) == "dead"

    if done then
        if self.callback ~= nil then
            self.callback()
        end
    end

    return done
end

---@class CoRunner
---@field Execute fun(self:table, func:function, callback:function) Executes the function in a coroutine and when it returns, calls callback, also in a coroutne.
---@field Delay fun(self:table, func:function, timeout:number) Executes the function after the given timeout.
---@field Terminate fun(self:table) Terminates the corunner and any runners.

local CoRunner = {}
CoRunner.__index = CoRunner
local idCount = 0

function CoRunner.New(interval)

    local s = {
        runner = {},
        main = nil, ---@type thread
        id = "CoRunner" .. idCount
    }

    idCount = idCount + 1

    -- The main routine, of the coRunner
    function s:work()
        while true do
            for i, r in ipairs(s.runner) do
                local done = r:Run()
                if done then
                    table.remove(s.runner, i)

                    --[[if #self.runner == 0 then
                    system.print("All coroutines have finished")
                end]] --

                    break
                end
                coroutine.yield()
            end
            coroutine.yield()
        end
    end

    -- Runs the corunner, called from a tick
    function s:run()
        if #s.runner > 0 then
            if s.main == nil or coroutine.status(s.main) == "dead" then
                s.main = coroutine.create(function()
                    s:work()
                end)
            end

            if coroutine.status(s.main) == "suspended" then
                coroutine.resume(s.main)
            end
        end
    end

    function s:Terminate()
        timer:Remove(s.id)
        s.runner = {}
        s.main = nil
    end

    --- Executes a coroutine, calling the callback when the routine dies.
    function s:Execute(func, callback)
        local r = newRunner(func, callback)
        table.insert(s.runner, #s.runner + 1, r)
        return self -- Allow chaining calls.
    end

    --- Delays the execution of func by timeout
    function s:Delay(func, timeout)
        s:Execute(
            function()
                local stop = Stopwatch.New()
                stop:Start()
                -- Yield until time has passed
                while stop:Elapsed() < timeout do
                    coroutine.yield()
                end
            end,
            function()
                func()
            end
        )
        return self -- Allow chaining calls
    end

    local instance = setmetatable(s, CoRunner)

    timer:Add(s.id, function()
        s:run()
    end, interval)

    return instance
end

return CoRunner
