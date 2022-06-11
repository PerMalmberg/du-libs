-- Handles function registration/deregistration of tick functions

local tick = {}
tick.__index = tick

local singleton = nil


local function new()
    local instance = {}
    instance.functions = {}
    return setmetatable(instance, tick)
end

function tick:Add(id, func, interval)
    self:Remove(id)

    self.functions[id] = func
    unit.setTimer(id, interval)
end

function tick:Remove(id)
    if self.functions[id] ~= nil then
        unit.stopTimer(id)
        self.functions[id] = nil
    end
end

--- Call this from script.OnTick()
---@param tickId any
function tick:Run(tickId)
    local f = self.functions[tickId]
    if f ~= nil then
        f()
    end
end

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                if singleton == nil then
                    singleton = new()
                end
                return singleton
            end
        }
)