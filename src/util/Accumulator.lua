local Ternary = require("util/Calc").Ternary

---@class Accumulator
---@field New fun(backlogCount:number, evaluator:function)
---@field Add fun(value:number):number
---@field Avg fun():number


local Accumulator = {}
Accumulator.__index = Accumulator

---@param backlogCount number
---@param evaluator function
---@return Accumulator
function Accumulator.New(backlogCount, evaluator)
    local s = {}

    local log = {}

    ---@param value number
    ---@return number
    function s.Add(value)
        table.insert(log, 1, evaluator(value))
        while #log >= backlogCount do
            table.remove(log)
        end

        return s.Avg()
    end

    ---@return number
    function s.Avg()
        local sum = 0
        for _, v in ipairs(log) do
            sum = sum + v
        end

        return sum / #log
    end

    return setmetatable(s, Accumulator)
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
