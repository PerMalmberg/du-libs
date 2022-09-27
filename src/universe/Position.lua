---Represents a position in the universe.

local checks = require("debug/Checks")
local Vec3 = require("cpml/vec3")
local stringFormat = string.format

---@class Position
---@field New fun(galaxy:integer, bodyRef:Body, x:integer, y:integer, z:integer):Position Creates a new Position
---@field AsPosString fun(self:Position):string returns a ::pos{} string
---@field Coordinates fun(self:Position):Vec3 returns the coordinates

local Position = {}
Position.__index = Position

---Creates a new position from the galaxy, body and x,y and z coordinates
---@param galaxy Galaxy The Galaxy the position belongs in
---@param bodyRef Body The closest body
---@param x number World X coordinate
---@param y number World Y coordinate
---@param z number World Z coordinate
---@return Position
function Position.New(galaxy, bodyRef, x, y, z)
    checks.IsTable(galaxy, "galaxy", "Position:new")
    checks.IsTable(bodyRef, "bodyRef", "Position:new")
    checks.IsNumber(x, "X", "Position:new")
    checks.IsNumber(y, "Y", "Position:new")
    checks.IsNumber(z, "Z", "Position:new")

    local s = {
        Body = bodyRef,
        Galaxy = galaxy,
        Coords = Vec3(x, y, z)
    }

    function s:AsPosString()
        return tostring(s)
    end

    ---Returns the coordinates of the position
    ---@return Vec3
    function Position:Coordinates()
        return s.Coords
    end

    function s:__tostring()
        -- The game starts giving space coordinates at an altitude of 70km above
        -- the planets radius on Alioth so we're mimicing that behaviour.
        local altitude = (s.Coords - s.Body.Geography.Center):len() - s.Body.Geography.Radius
        if altitude < s.Body.Geography.Radius + 70000 then
            -- Use a radius that includes the altitude
            local radius = s.Body.Geography.Radius + altitude
            -- Calculate around origo; planet center is added in Universe:ParsePosition
            -- and we're reversing that calculation.
            local calcPos = s.Coords - s.Body.Geography.Center
            local lat = math.asin(calcPos.z / radius)
            local lon = math.atan(calcPos.y, calcPos.x)

            return stringFormat("::pos{%d,%d,%.4f,%.4f,%.4f}", s.Galaxy.Id, s.Body.Id, math.deg(lat), math.deg(lon),
                altitude)
        else
            return stringFormat("::pos{%d,0,%.4f,%.4f,%.4f}", s.Galaxy.Id, s.Coords.x, s.Coords.y, s.Coords.z)
        end
    end

    return setmetatable(s, Position)
end

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
