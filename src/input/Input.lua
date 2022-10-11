local keys = require("input/Keys")

---@alias InputCallback fun()
---@alias CallbackPair {criteria:Criteria, func:InputCallback}

---@class Input
---@field Instance fun():Input
---@field Register fun(key:Keys, criteria:Criteria, callback:InputCallback)
---@field IsPressed fun(key:Keys):boolean

local Input = {}
Input.__index = Input
local singleton

function Input.Instance()
    if singleton then
        return singleton
    end

    local s = {}
    local lookup = {} ---@type table<Keys, CallbackPair[]>
    local keyState = {} ---@type table<Keys, boolean>

    -- Create handles for each of the known input actions
    for _, k in ipairs(keys) do
        -- Start with all keys in released state
        keyState[k] = false
    end

    function s.decode(key, isPressed, isRepeat)
        keyState[key] = isPressed

        local l = lookup[key]
        if l ~= nil then
            for _, entry in ipairs(l) do
                if entry.criteria.Matches(s, isRepeat, isPressed) then
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

    ---Indicates if a key is pressed
    ---@param key Keys
    ---@return boolean
    function s.IsPressed(key)
        return keyState[key]
    end

    ---Register a function to be triggered when a key is pressed and certain modifiers are set
    ---@param key Keys
    ---@param criteria Criteria
    ---@param callback InputCallback
    function s.Register(key, criteria, callback)
        key = keys[key]
        local cbPair = lookup[key]

        if cbPair == nil then
            cbPair = {}
            lookup[key] = cbPair
        end

        table.insert(cbPair, { criteria = criteria, func = callback })
    end

    singleton = setmetatable(s, Input)

    system:onEvent("onActionStart", s.keyPress, s)
    system:onEvent("onActionStop", s.keyRelease, s)
    system:onEvent("onActionLoop", s.keyHold, s)

    return singleton
end

return Input
