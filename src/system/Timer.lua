local utc = system.getUtcTime

local timer = {}
timer.__index = timer

local function new()
    local t = {
        startTime = nil,
        stopTime = nil
    }
    return setmetatable(t, timer)
end

function timer:Start()
    self.startTime = utc()
    self.stopTime = nil
end

function timer:Stop()
    self.stopTime = utc()
end

---@return number Elapsed time, in seconds with fractions.
function timer:Elapsed()
    if self.startTime == nil then
        return 0
    elseif self.stopTime == nil then
        return utc() - self.startTime
    else
        return self.stopTime - self.startTime
    end
end

function timer:IsRunning()
    return self.startTime ~= nil and self.endTime == nil
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