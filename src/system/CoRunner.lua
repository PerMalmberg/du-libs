local timer = require("system/Timer")()
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

local idCount = 0
local coRunner = {}
coRunner.__index = coRunner

local function new(interval)
    local instance = {
        runner = {},
        main = nil,
        id = idCount
    }

    setmetatable(instance, coRunner)

    timer:Add("CoRunner" .. idCount, function()
        instance:run()
    end, interval)

    idCount = idCount + 1

    return instance
end

-- Runs the corunner, called from a tick
function coRunner:run()
    if #self.runner > 0 then
        if self.main == nil or coroutine.status(self.main) == "dead" then
            self.main = coroutine.create(function()
                self:work()
            end)
        end

        if coroutine.status(self.main) == "suspended" then
            coroutine.resume(self.main, self)
        end
    end
end

-- The main routine, of the coRunner
function coRunner:work()
    while true do
        for i, r in ipairs(self.runner) do
            local done = r:Run()
            if done then
                table.remove(self.runner, i)

                --[[if #self.runner == 0 then
                    system.print("All coroutines have finished")
                end]]--

                break
            end
            coroutine.yield()
        end
        coroutine.yield()
    end
end

function coRunner:Terminate()
    timer:Remove(self.id)
end

--- Executes a coroutine, calling the callback when the routine dies.
function coRunner:Execute(func, callback)
    local r = newRunner(func, callback)
    table.insert(self.runner, #self.runner + 1, r)
    return self -- Allow chaining calls.
end

--- Delays the execution of func by timeout
function coRunner:Delay(func, timeout)
    self:Execute(
            function()
                local stop = Stopwatch()
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

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                return new(...)
            end
        }
)