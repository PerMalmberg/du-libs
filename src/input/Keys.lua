---@class Keys
local Keys = {}
Keys.__index = Keys

Keys["lshift"] = 1
Keys["lalt"] = 2
Keys["brake"] = 3
Keys.FirstNonModifier = 4 -- this is the first key that Register() will accept
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
Keys["option10"] = 32
Keys["option11"] = 33
Keys["option12"] = 34
Keys["option13"] = 35
Keys["option14"] = 36
Keys["option15"] = 37
Keys["option16"] = 38
Keys["option17"] = 39
Keys["option18"] = 40
Keys["option19"] = 41
Keys["option20"] = 42
Keys["option21"] = 43
Keys["option22"] = 44
Keys["option23"] = 45
Keys["option24"] = 46
Keys["option25"] = 47
Keys["option26"] = 48
Keys["option27"] = 49
Keys["option28"] = 50
Keys["option29"] = 51

local indexToName = {}
for key, value in pairs(Keys) do
    indexToName[value] = key
end

---Returns the name of the key
---@param value integer
---@return string
function Keys.Name(value)
    return indexToName[value] or "unknown key"
end

return setmetatable({}, Keys)
