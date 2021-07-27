-- Handles function registration/deregistration of tick functions

Tick = {}
local instance = nil

function Tick:Instance()
    if instance == nil then
        instance = {}
        instance.functions = {}
        setmetatable(instance, self)
        self.__index = self
    end

    return instance
end

function Tick:Add(id, func, interval)
    self:Remove(id)

    self.functions[id] = func
    unit.setTimer(id, interval)
end

function Tick:Remove(id)
    if self.functions[id] ~= nil then
        unit.stopTimer(id)
        self.functions[id] = nil
    end
end

--- Call this from script.OnTick()
---@param tickId any
function Tick:Run(tickId)
    local f = self.functions[tickId]
    if f ~= nil then
        f()
    end
end