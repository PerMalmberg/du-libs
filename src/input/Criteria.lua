local keys = require("input/Keys")

---@class Criteria
---@field Matches fun(input:Input, isRepeat:boolean, isPressed:boolean):boolean
---@field LShift fun()
---@field LCtrl fun()
---@field LAlt fun()
---@field OnPress fun()
---@field OnRelease fun()
---@field OnRepeat fun()

local Criteria = {}
Criteria.__index = Criteria

function New()
    local s = {}
    local requiredMods = {}
    local onRepeat = false
    local onPress = false
    local onRelease = false

    function s.Matches(input, isRepeat, isPressed)
        if (isRepeat and not s.onRepeat) then
            return false
        elseif not isRepeat then

            if (not s.onPress and not s.onRelease) then
                return false
            end

            if not ((s.onPress and isPressed) or (s.onRelease and not isPressed)) then
                return false
            end
        end

        for _, k in pairs(s.requiredMods) do
            if not input.IsPressed(k) then
                return false
            end
        end

        return true
    end

    function s.__tostring()
        local str = ""
        for _, c in pairs(s.requiredMods) do
            str = str .. " " .. c
        end

        return "s." .. str
    end

    function s.LShift()
        table.insert(s.requiredMods, keys.lshift)
        return s
    end

    function s.LCtrl()
        table.insert(s.requiredMods, keys.brake)
        return s
    end

    function s.LAlt()
        table.insert(s.requiredMods, keys.lalt)
        return s
    end

    function s.OnPress()
        s.onPress = true
        return s
    end

    function s.OnRelease()
        s.onRelease = true
        return s
    end

    function s.OnRepeat()
        s.onRepeat = true
        return s
    end

    setmetatable(s, Criteria)

    return s
end

return Criteria
