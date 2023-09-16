local keys = require("input/Keys")

---@class Criteria
---@field Matches fun(input:Input, isRepeat:boolean, isPressed:boolean):boolean
---@field LShift fun():Criteria
---@field IgnoreLShift fun():Criteria
---@field LCtrl fun():Criteria
---@field IgnoreLCtrl fun():Criteria
---@field OnPress fun():Criteria
---@field OnRelease fun():Criteria
---@field OnRepeat fun():Criteria

local Criteria = {}
Criteria.__index = Criteria

function Criteria.New()
    local s = {}
    local requiredMods = {} ---@type integer[]
    local prohibitedMods = { [keys.lshift] = true, [keys.brake] = true } ---@type table<integer,boolean>
    local onRepeat = false
    local onPress = false
    local onRelease = false
    local lastPressed = false -- when reacting to release events, we must know that we've been pressed first

    ---Checks if the key events matches the set criterias
    ---@param input Input
    ---@param isRepeat boolean
    ---@param isPressed boolean
    ---@return boolean
    function s.Matches(input, isRepeat, isPressed)
        local released = onRelease and not isPressed

        if not onRepeat and isRepeat then
            return false
        end

        -- This check does not work with checking released keys, when the key is also a modifier key.
        -- Only when pressing the key
        if isPressed then
            for _, k in pairs(requiredMods) do
                if not input.IsPressed(k) then
                    return false
                end
            end

            -- Also need to check that other modifier keys are *not* pressed
            for k, v in pairs(prohibitedMods) do
                if v and input.IsPressed(k) then
                    return false
                end
            end

            lastPressed = true
        end

        if released then
            if not lastPressed then
                return false
            end

            lastPressed = false
        end

        return (onRepeat and isRepeat) or (onPress and isPressed) or released
    end

    function Criteria.__tostring()
        local str = ""
        for _, c in pairs(requiredMods) do
            str = str .. " " .. c
        end

        return "" .. str
    end

    -- Q: Where is Alt key?
    -- A: The game doesn't pass that though to us

    ---Requires left shift to be pressed
    ---@return Criteria
    function s.LShift()
        table.insert(requiredMods, keys.lshift)
        prohibitedMods[keys.lshift] = false
        return s
    end

    ---Requires left control to be pressed
    ---@return Criteria
    function s.LCtrl()
        table.insert(requiredMods, keys.brake)
        prohibitedMods[keys.brake] = false
        return s
    end

    ---@return Criteria
    function s.IgnoreLCtrl()
        prohibitedMods[keys.brake] = false
        return s
    end

    ---@return Criteria
    function s.IgnoreLShift()
        prohibitedMods[keys.lshift] = false
        return s
    end

    ---Makes the critera match when the button is pressed
    ---@return Criteria
    function s.OnPress()
        onPress = true
        return s
    end

    ---Makes the criteria match when the button is released.
    ---@return Criteria
    function s.OnRelease()
        onRelease = true
        return s
    end

    ---Makes the critera match when the button is repeated
    ---@return Criteria
    function s.OnRepeat()
        onRepeat = true
        return s
    end

    return setmetatable(s, Criteria)
end

return Criteria
