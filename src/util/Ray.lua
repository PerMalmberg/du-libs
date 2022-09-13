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