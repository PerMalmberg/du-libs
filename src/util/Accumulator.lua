local Ternary = require("util/Calc").Ternary

local Accumulator = {}
Accumulator.__index = Accumulator
function Accumulator:New(backlogCount, evaluator)
    local self = {}

    local log = {}

    function self:Add(value)
        table.insert(log, 1, evaluator(value))
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

--- Makes the accumulator return a value between 0 and 1 indicating if added values are mostly true or false.
Accumulator.Truth = function(value)
    return Ternary(value, 1, 0)
end

--- Makes the accumulator return the average value of the added values
Accumulator.SumAvg = function(value)
    return value
end

return Accumulator