---@class Keys
local Keys = {}
Keys.__index = Keys

Keys["lshift"] = 1
Keys["lalt"] = 2
Keys["brake"] = 3
Keys["forward"] = 4
Keys["backward"] = 5
Keys["yawleft"] = 6
Keys["yawright"] = 7
Keys["strafeleft"] = 8
Keys["straferight"] = 9
Keys["left"] = 10
Keys["right"] = 11
Keys["up"] = 12
Keys["down"] = 13
Keys["groundaltitudeup"] = 14
Keys["groundaltitudedown"] = 15
Keys["gear"] = 16
Keys["light"] = 17
Keys["stopengines"] = 18
Keys["speedup"] = 19
Keys["speeddown"] = 20
Keys["antigravity"] = 21
Keys["booster"] = 22
Keys["option1"] = 23
Keys["option2"] = 24
Keys["option3"] = 25
Keys["option4"] = 26
Keys["option5"] = 27
Keys["option6"] = 28
Keys["option7"] = 29
Keys["option8"] = 30
Keys["option9"] = 31

---Returns the name of the key
---@param value integer
---@return string
function Keys.Name(value)
    for key, v in pairs(Keys) do
        if value == v then
            return key
        end
    end

    return "unknown key"
end

return setmetatable({}, Keys)
