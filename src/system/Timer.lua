-- Handles function registration/deregistration of tick functions

local timer = {}
timer.__index = timer

local singleton

local function new()
    local instance = {}
    instance.functions = {}
    setmetatable(instance, timer)

    -- Register with du-luac event handler
    unit:onEvent("onTimer", function(unit, id)
        instance:run(id)
    end)
    return instance
end

function timer:Add(id, func, interval)
    self:Remove(id)

    self.functions[id] = func
    unit.setTimer(id, interval)
end

function timer:Remove(id)
    if self.functions[id] ~= nil then
        unit.stopTimer(id)
        self.functions[id] = nil
    end
end

---@param tickId any
function timer:run(tickId)
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