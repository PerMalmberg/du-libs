local Ternary = require("util/Calc").Ternary

local Accumulator = {}
Accumulator.__index = Accumulator
function Accumulator:New(backlogCount)
    local self = {}

    local log = {}

    function self:Add(value)
        table.insert(log, 1, Ternary(value, 1, 0))
        while #log >= backlogCount do
            table.remove(log)
        end

        return self:Avg()
    end

    function self:Avg()
        local sum = 0
        for _, v in ipairs(log) do
            sum = sum + v
        end

        return sum / #log
    end

    return setmetatable(self, Accumulator)
end

return Accumulator