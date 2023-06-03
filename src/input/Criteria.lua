local keys = require("input/Keys")

---@class Criteria
---@field Matches fun(input:Input, isRepeat:boolean, isPressed:boolean):boolean
---@field LShift fun():Criteria
---@field LCtrl fun():Criteria
---@field LAlt fun():Criteria
---@field OnPress fun():Criteria
---@field OnRelease fun():Criteria
---@field OnRepeat fun():Criteria

local Criteria = {}
Criteria.__index = Criteria

function Criteria.New()
    local s = {}
    local requiredMods = {} ---@type integer[]
    local onRepeat = false
    local onPress = false
    local onRelease = false

    ---Checks if the key events matches the set criterias
    ---@param input Input
    ---@param isRepeat boolean
    ---@param isPressed boolean
    ---@return boolean
    function s.Matches(input, isRepeat, isPressed)
        if (isRepeat and not onRepeat) then
            return false
        elseif not isRepeat then
            if (not onPress and not onRelease) then
                return false
            end

            if not ((onPress and isPressed) or (onRelease and not isPressed)) then
                return false
            end
        end

        -- This check does not work with checking released keys, when the key is also a modifier key.
        for _, k in pairs(requiredMods) do
            if not input.IsPressed(k) then
                return false
            end
        end

        return true
    end

    function Criteria.__tostring()
        local str = ""
        for _, c in pairs(requiredMods) do
            str = str .. " " .. c
        end

        return "" .. str
    end

    ---Requires left shift to be pressed
    ---@return Criteria
    function s.LShift()
        table.insert(requiredMods, keys.lshift)
        return s
    end

    ---Requires left control to be pressed
    ---@return Criteria
    function s.LCtrl()
        table.insert(requiredMods, keys.brake)
        return s
    end

    ---Requires left alt to be pressed
    ---@return Criteria
    function s.LAlt()
        table.insert(requiredMods, keys.lalt)
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
