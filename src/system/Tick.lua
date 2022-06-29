-- Handles function registration/deregistration of tick functions

local tick = {}
tick.__index = tick

local singleton = nil

local function new()
    local instance = {}
    instance.functions = {}
    setmetatable(instance, tick)

    -- Register with du-luac event handler
    unit:onEvent("onTick", function(system, id)
        instance:run(id)
    end)
    return instance
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
function tick:run(tickId)
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