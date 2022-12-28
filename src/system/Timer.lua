---@class Timer Handles function registration/deregistration of tick functions
---@field Instance fun():Timer Returns the singleton instance
---@field Add fun(id:string, func:function, interval:number) Adds a timer with the given interval and callback function.
---@field Remove fun(id:string) Removes a timer with the given id.
local Timer = {}
Timer.__index = Timer

local singleton ---@type Timer

---Returns a Timer instance
---@return Timer
function Timer.Instance()
    if singleton then
        return singleton
    end

    local s = {}
    local functions = {}

    function s:Add(id, func, interval)
        s:Remove(id)

        functions[id] = func
        unit.setTimer(id, interval)
    end

    function s:Remove(id)
        if functions[id] ~= nil then
            unit.stopTimer(id)
            functions[id] = nil
        end
    end

    ---@param tickId any
    local function run(tickId)
        local f = functions[tickId]
        if f ~= nil then
            f()
        end
    end

    -- Register with du-luac event handler
    unit:onEvent("onTimer", function(unit, id)
        run(id)
    end)

    singleton = setmetatable(s, Timer)
    return singleton
end

return Timer
