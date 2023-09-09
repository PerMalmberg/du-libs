-- Body - stellar body

require("system/locale")
local Vec3 = require("math/Vec3")
local abs = math.abs

local max = math.max

---@module "Galaxy"

---@class Body
---@field Galaxy Galaxy The galaxy the body resides in
---@field Id number The body ID
---@field Name string The name of the body
---@field Type string The type of the body
---@field Physics { Gravity:number } Physics properties
---@field Geography { Center:Vec3, Radius:number} Geography properties
---@field Atmosphere {Present:boolean, Thickness:number, Radius:number} Atmosphere properties
---@field Surface {MaxAltitude:number, MinAltitude:number}} Surface properties
---@field PvP {LocatedInSafeZone:boolean} Pvp properties
---@field DistanceToAtmo fun(self:Body, point:Vec3):number
---@field DistanceToAtmoEdge fun(self:Body, point:Vec3):number
---@field HasAtmo fun():boolean
---@field IsInAtmo fun(self:Body, point:Vec3):boolean
---@field DistanceToHighestPossibleSurface fun(coordinate:Vec3):number
---@field AboveSeaLevel fun(coordinate:Vec3):boolean, number

local Body = {}
Body.__index = Body

---@param galaxy table
---@param bodyData table
---@return Body
function Body.New(galaxy, bodyData)
    local language = LocaleIndex()

    local s = {
        ---@type Body
        Galaxy = galaxy,
        Id = bodyData.id,
        Name = bodyData.name[language],
        Type = bodyData.type[language],
        Physics = {
            Gravity = bodyData.gravity
        },
        Geography = {
            Center = Vec3.New(bodyData.center),
            Radius = bodyData.radius -- This is the water level, i.e. 0 elevation
        },
        Atmosphere = {
            Present = bodyData.hasAtmosphere,
            Thickness = bodyData.atmosphereThickness,
            Radius = bodyData.atmosphereRadius
        },
        Surface = {
            MaxAltitude = bodyData.surfaceMaxAltitude,
            MinAltitude = bodyData.surfaceMinAltitude
        },
        Pvp = {
            LocatedInSafeZone = bodyData.isInSafeZone
        }
    }

    function Body.__tostring(instance)
        return instance.Name
    end

    ---Returns the distance between the given position and the atmosphere of the body, 0 if already in atmosphere of the body
    ---@param coordinate Vec3
    ---@return number
    function s:DistanceToAtmo(coordinate)
        return max(0, (coordinate - s.Geography.Center):Len() - s.Atmosphere.Radius)
    end

    ---Returns the distance to the edge of the atmosphere, from the given position
    ---@param coordinate Vec3
    function s:DistanceToAtmoEdge(coordinate)
        local dist = s:DistanceToAtmo(coordinate)
        if dist == 0 then
            -- Inside atmo
            return s.Atmosphere.Radius - (coordinate - s.Geography.Center):Len()
        end

        return dist
    end

    ---Returns true if the coordinate is within the atmosphere of the body
    ---@param coordinate any
    ---@return boolean
    function s:IsInAtmo(coordinate)
        return s:DistanceToAtmo(coordinate) == 0
    end

    ---Returns true if the body has an atmosphere
    ---@return boolean
    function s:HasAtmo()
        return s.Atmosphere.Radius > 0
    end

    ---Returns the distance to the highest possible point on the body or 0 if below higest surface
    ---@param coordinate Vec3
    ---@return number
    function s.DistanceToHighestPossibleSurface(coordinate)
        return max(0, (coordinate - s.Geography.Center):Len() - s.Geography.Radius - s.Surface.MaxAltitude)
    end

    ---Returns a boolean indicating if the coordinate is above sea level and a number representing the absolute distance to the sea level
    ---@param coordinate Vec3 The coordinate to get info on.
    ---@return boolean, number
    function s.AboveSeaLevel(coordinate)
        local seaLevel = s.Geography.Radius
        local distanceToCenter = (coordinate - s.Geography.Center):Len()
        return distanceToCenter >= seaLevel, abs(distanceToCenter - seaLevel)
    end

    return setmetatable(s, Body)
end

return Body
