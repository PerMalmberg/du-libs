---@class Ray
---@field New fun(start:Vec3, direction:Vec3):Ray
---@field Start Vec3 The start point of the ray
---@field Dir Vec3 The direction the ray points

local Ray = {}
Ray.__index = Ray
function Ray:New(start, direction)
    local s = {
        Start = start,
        Dir = direction
    }

    return setmetatable(s, Ray)
end

return Ray
