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
Keys["option0"] = 23
Keys["option1"] = 24
Keys["option2"] = 25
Keys["option3"] = 26
Keys["option4"] = 27
Keys["option5"] = 28
Keys["option6"] = 29
Keys["option7"] = 30
Keys["option8"] = 31
Keys["option9"] = 32
Keys["option10"] = 33
Keys["option11"] = 34
Keys["option12"] = 35
Keys["option13"] = 36
Keys["option14"] = 37
Keys["option15"] = 38
Keys["option16"] = 39
Keys["option17"] = 40
Keys["option18"] = 41
Keys["option19"] = 42
Keys["option20"] = 43
Keys["option21"] = 44
Keys["option22"] = 45
Keys["option23"] = 46
Keys["option24"] = 47
Keys["option25"] = 48
Keys["option26"] = 49
Keys["option27"] = 50
Keys["option28"] = 51
Keys["option29"] = 52

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
