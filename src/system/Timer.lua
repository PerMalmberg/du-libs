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
    local toRemove = {} ---@type string[]
    local toAdd = {} ---@type {id:string, f:fun(), interval:number}

    function s.Add(id, func, interval)
        s.Remove(id)
        toAdd[#toAdd + 1] = { id = id, f = func, interval = interval }
        functions[id] = func
    end

    function s.Remove(id)
        if functions[id] ~= nil then
            toRemove[#toRemove + 1] = id
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

    -- Can't call unit.stopTimer/startTimer from flush so to anbled that possibility,
    -- we do it via the update event. The timers are based on framerate anyhow so the
    -- delay this induces is of no consequence.
    system:onEvent("onUpdate", function()
        while #toRemove > 0 do
            unit.stopTimer(table.remove(toRemove, 1))
        end
        while #toAdd > 0 do
            local add = table.remove(toAdd, 1)
            unit.setTimer(add.id, add.interval)
        end
    end)

    -- Register with du-luac event handler
    unit:onEvent("onTimer", function(unit, id)
        run(id)
    end)

    singleton = setmetatable(s, Timer)
    return singleton
end

return Timer
