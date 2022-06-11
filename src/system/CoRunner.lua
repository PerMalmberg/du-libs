local tick = require("system/Tick")()
local Timer = require("system/Timer")

local runner = {}
runner.__index = runner

local function newRunner(func, callback)
    o = {
        co = coroutine.create(func),
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
        main = nil
    }

    setmetatable(instance, coRunner)

    tick:Add("CoRunnerTick" .. idCount,
            function()
                instance:run()
            end,
            interval)

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
                local timer = Timer()
                timer:Start()
                -- Yield until time has passed
                while timer:Elapsed() < timeout do
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