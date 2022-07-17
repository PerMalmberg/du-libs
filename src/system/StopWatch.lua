local utc = system.getUtcTime

local stopwatch = {}
stopwatch.__index = stopwatch

local function new()
    local t = {
        startTime = nil,
        stopTime = nil
    }
    return setmetatable(t, stopwatch)
end

function stopwatch:Start()
    self.startTime = utc()
    self.stopTime = nil
end

function stopwatch:Stop()
    self.stopTime = utc()
end

---@return number Elapsed time, in seconds with fractions.
function stopwatch:Elapsed()
    if self.startTime == nil then
        return 0
    elseif self.stopTime == nil then
        return utc() - self.startTime
    else
        return self.stopTime - self.startTime
    end
end

function stopwatch:IsRunning()
    return self.startTime ~= nil and self.stopTime == nil
end

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                return new()
            end
        }
)