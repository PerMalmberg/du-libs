local keys = require("input/Keys")

---@class Input
---@field Instance fun():Input

local Input = {}
Input.__index = Input
local singleton

function Input.Instance()
    if singleton then
        return singleton
    end

    local s = {}
    local lookup = {}
    local keyState = {}

    function s.decode(key, isPressed, isRepeat)
        keyState[key] = isPressed

        local l = lookup[key]
        if l ~= nil then
            for _, entry in ipairs(l) do
                if entry.criteria:Matches(s, isRepeat, isPressed) then
                    entry.func()
                end
            end
        end
    end

    function s.keyPress(key)
        s.decode(key, true, false)
    end

    function s.keyRelease(key)
        s.decode(key, false, false)
    end

    function s.keyHold(key)
        s.decode(key, true, true)
    end

    function s.IsPressed(key)
        return keyState[key]
    end

    ---Register a function to be triggered when a key is pressed and certain modifiers are set
    ---@param key Keys
    ---@param criteria Criteria
    ---@param func any
    function s.Register(key, criteria, func)
        key = keys[key]
        local l = lookup[key]

        if l == nil then
            l = {}
            lookup[key] = l
        end

        table.insert(l, { criteria = criteria, func = func })
    end

    singleton = setmetatable(s, Input)

    -- Create handles for each of the known input actions
    for _, k in ipairs(keys) do
        -- Start with all keys in released state
        s.keyState[k] = false
    end

    system:onEvent("onActionStart", s.keyPress, s)
    system:onEvent("onActionStop", s.keyRelease, s)
    system:onEvent("onActionLoop", s.keyHold, s)

    return singleton
end

return Input
