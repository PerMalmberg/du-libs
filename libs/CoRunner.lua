require("Tick")

CoRunner = {}
CoRunnerTimerId = "CoRunnerTimer"

Runner = {}

function Runner:New(func, callback)
    o = {}
    o.co = coroutine.create(func)
    o.callback = callback
    setmetatable(o, self)
    self.__index = self

    return o
end

function Runner:Run()
    coroutine.resume(self.co)
    
    local done = coroutine.status(self.co) == "dead"

    if done then
        if self.callback ~= nil then
            self.callback()
        end
    end

    return done
end


function CoRunner:Instance()
    if instance == nil then
        instance = {}
        instance.runner = {}
        instance.main = nil
        setmetatable(instance, self)
        self.__index = self
    end

    return instance
end

-- Installs the CoRunner, with a tick of 'interval'.
function CoRunner:Install(interval)
    Tick:Instance():Add("corunner", function() self:run() end, interval)
end

-- Runs the corunner, called from a tick
function CoRunner:run()
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

-- The main routine, of the CoRunner
function CoRunner:work()
    while true do
        for i, runner in ipairs(self.runner) do
            local done = runner:Run()
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
function CoRunner:Execute(func, callback)
    local r = Runner:New(func, callback)
    table.insert(self.runner, #self.runner + 1, r)
    return self -- Allow chaining Execute-calls.
end

function CoRunner:Delay(func, seconds)
    self:Execute(
        function() 
            local start = system.getTime()
            local endTime = start + seconds

            -- Yield until time has passed
            while system.getTime() < endTime do
                coroutine.yield();
            end

            -- Call function
            func()
        end    
    )
end

