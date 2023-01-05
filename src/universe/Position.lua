---Represents a position in the universe.

local checks = require("debug/Checks")
local stringFormat = string.format

---@class Position
---@field New fun(galaxy:integer, bodyRef:Body, x:integer, y:integer, z:integer):Position Creates a new Position
---@field AsPosString fun():string returns a ::pos{} string
---@field Coordinates fun():Vec3 returns the coordinates

local Position = {}
Position.__index = Position

---Creates a new position from the galaxy, body and x,y and z coordinates
---@param galaxy Galaxy The Galaxy the position belongs in
---@param bodyRef Body The closest body
---@param coordinate Vec3 World coordinates
---@return Position
function Position.New(galaxy, bodyRef, coordinate)
    checks.IsTable(galaxy, "galaxy", "Position:new")
    checks.IsTable(bodyRef, "bodyRef", "Position:new")
    checks.IsVec3(coordinate, "coordinate", "Position:new")

    local s = {
        Body = bodyRef,
        Galaxy = galaxy,
        Coords = coordinate
    }

    function s.AsPosString()
        return tostring(s)
    end

    ---Returns the coordinates of the position
    ---@return Vec3
    function s.Coordinates()
        return s.Coords
    end

    function Position.__tostring(p) -- __tostring must be in the metatable, not the instance
        local res
        -- The game starts giving space coordinates at an altitude of 70km above
        -- the planets radius on Alioth so we're mimicing that behaviour.
        local altitude = (p.Coords - p.Body.Geography.Center):Len() - p.Body.Geography.Radius
        if altitude < p.Body.Geography.Radius + 70000 then
            -- Use a radius that includes the altitude
            local radius = p.Body.Geography.Radius + altitude
            -- Calculate around origo; planet center is added in Universe:ParsePosition
            -- and we're reversing that calculation.
            local calcPos = p.Coords - p.Body.Geography.Center

            local lat = 0
            local lon = 0

            -- When the input coordinates are the same as the center of the planet, trigonomitry fails so just leave them at 0.
            if calcPos:Len2() > 0 then
                lat = math.asin(calcPos.z / radius)
                lon = math.atan(calcPos.y, calcPos.x)
            end

            return stringFormat("::pos{%d,%d,%.4f,%.4f,%.4f}", p.Galaxy.Id, p.Body.Id, math.deg(lat), math.deg(lon),
                altitude)
        else
            return stringFormat("::pos{%d,0,%.4f,%.4f,%.4f}", p.Galaxy.Id, p.Coords.x, p.Coords.y, p.Coords.z)
        end
    end

    return setmetatable(s, Position)
end

return Position

--[[
---Calculates the distance 'as the crow flies' to the other position
---using the haversine formula
---@param other Position The position to calculate the distance to.
function position:DistanceAtHeight(other)
    -- http://www.movable-type.co.uk/scripts/latlong.html
    if self.Body.Id == other.Body.Id then

    else

    end

    return nil
end
]]
