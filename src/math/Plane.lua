require("abstraction/Vehicle")
local universe = require("universe/Universe").Instance()

---@alias Fun3 fun():Vec3

---@class Plane
---@field Up fun():Vec3
---@field Right fun():Vec3
---@field Forward fun():Vec3
---@field NewByVertialReference fun():Plane
---@field New fun(f:Fun3):Plane

local Plane = {}
Plane.__index = Plane

---comment
---@param verticalFunc fun():Vec3
---@return Plane
function Plane.New(verticalFunc)
    local s = {}
    local constructRight = Right

    s.Up = verticalFunc

    function s.Forward()
        return s.Up():Cross(constructRight())
    end

    function s.Right()
        -- Forward x Up instead of Up x Forward to get right instead of left dir
        return s.Forward():Cross(s.Up())
    end

    return setmetatable(s, Plane)
end

function Plane.NewByVertialReference()
    local up = universe.VerticalReferenceVector
    return Plane.New(function() return -up() end)
end

return Plane
