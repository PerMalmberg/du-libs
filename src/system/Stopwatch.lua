---@class Stopwatch
---@field Start fun() Starts the stopwatch, or leaves it running if it already is.
---@field Restart fun() Restarts the stopwatch
---@field Stop fun() Stops the stopwatch
---@field Reset fun() Resets the stopwatch to a state as if it never had been started
---@field Elapsed fun():number Returns the number of seconds the stopwatch has been running.
---@field IsRunning fun():boolean Returns true if the stopwatch is currently running, i.e. started, and not stopped.

local Stopwatch = {}
Stopwatch.__index = Stopwatch

---Creates a new Stopwatch
---@return Stopwatch
function Stopwatch.New()
    local s = {}

    local utc = system.getUtcTime
    local startTime = nil
    local stopTime = nil

    ---Starts the stopwatch, or leaves it running if it already is.
    function s.Start()
        if not s.IsRunning() then
            startTime = utc()
            stopTime = nil
        end
    end

    ---Restarts the stopwatch
    function s.Restart()
        s.Stop()
        s.Start()
    end

    ---Stops the stopwatch
    function s.Stop()
        stopTime = utc()
    end

    ---Resets the stopwatch, Elapsed() will return 0 after this call
    function s.Reset()
        startTime = nil
        stopTime = nil
    end

    ---@return number # Elapsed time, in seconds with fractions.
    function s.Elapsed()
        if startTime == nil then
            return 0
        elseif stopTime == nil then
            return utc() - startTime
        else
            return stopTime - startTime
        end
    end

    ---Checks if the stopwatch is running
    ---@return boolean
    function s.IsRunning()
        return startTime ~= nil and stopTime == nil
    end

    return setmetatable(s, Stopwatch)
end

return Stopwatch
