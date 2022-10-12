local keys = require("input/Keys")

---@alias InputCallback fun()
---@alias CallbackPair {criteria:Criteria, func:InputCallback}

---@class Input
---@field Instance fun():Input
---@field Register fun(key:integer, criteria:Criteria, callback:InputCallback)
---@field IsPressed fun(key:integer):boolean

local Input = {}
Input.__index = Input
local singleton

function Input.Instance()
    if singleton then
        return singleton
    end

    local s = {}
    local lookup = {} ---@type table<Keys, CallbackPair[]>
    local keyState = {} ---@type table<integer, boolean>

    ---Decodes the event
    ---@param keyName string
    ---@param isPressed boolean
    ---@param isRepeat boolean
    function s.decode(keyName, isPressed, isRepeat)
        local key = keys[keyName]
        if key == nil then return end

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

    local function keyPress(_, key)
        s.decode(key, true, false)
    end

    local function keyRelease(_, key)
        s.decode(key, false, false)
    end

    local function keyRepeat(_, key)
        s.decode(key, true, true)
    end

    ---Indicates if a key is pressed
    ---@param key Keys
    ---@return boolean
    function s.IsPressed(key)
        return keyState[key] or false
    end

    ---Register a function to be triggered when a key is pressed and certain modifiers are set
    ---@param key integer
    ---@param criteria Criteria
    ---@param callback InputCallback
    function s.Register(key, criteria, callback)
        local cbPair = lookup[key]

        if cbPair == nil then
            cbPair = {}
            lookup[key] = cbPair
        end

        table.insert(cbPair, { criteria = criteria, func = callback })
    end

    singleton = setmetatable(s, Input)

    system:onEvent("onActionStart", keyPress)
    system:onEvent("onActionStop", keyRelease)
    system:onEvent("onActionLoop", keyRepeat)

    return singleton
end

return Input
