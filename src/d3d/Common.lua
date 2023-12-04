local NV3 = require("math/Vec3").New
local getPoint = library.getPointOnScreen

---@param v Vec3
---@return Vec3
D3dVecToScreen = function(v)
    return NV3(getPoint({ v:Unpack() }))
end
