-- Body - stellar body

require("system/locale")
local checks = require("debug/Checks")
local Vec3 = require("cpml/vec3")
local abs = math.abs

local max = math.max

---@module "Galaxy"

---@class Body
---@field Galaxy Galaxy The galaxy the body resides in
---@field Id number The body ID
---@field Name string The name of the body
---@field Type string The type of the body
---@field Physics { Gravity:number } Physics properties
---@field Geography { Center:vec3, Radius:number, MaxSurfaceAltitude:number} Geography properties
---@field Atmosphere {Present:boolean, Thickness:number, Radius:number} Atmosphere properties
---@field Surface table Surface properties
---@field PvP table Pvp properties
---@field DistanceToAtmo fun(self:Body, point:Vec3):number
---@field IsInAtmo fun(self:Body, point:Vec3):boolean
---@field DistanceToHighestPossibleSurface fun(coordinate:Vec3)
---@field AboveSeaLevel fun(coordinate:Vec3):boolean, number

local Body = {}
Body.__index = Body

function Body.New(galaxy, bodyData)
    checks.IsTable(galaxy, "galaxy", "body:Prepare")
    checks.IsTable(bodyData, "data", "body:Prepare")

    local language = LocaleIndex()

    local s = { ---@type Body
        Galaxy = galaxy,
        Id = bodyData.id,
        Name = bodyData.name[language],
        Type = bodyData.type[language],
        Physics = {
            Gravity = bodyData.gravity
        },
        Geography = {
            Center = Vec3(bodyData.center),
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
    ---@param coordinate vec3
    ---@return number
    function s:DistanceToAtmo(coordinate)
        return max(0, (coordinate - s.Geography.Center):len() - s.Atmosphere.Radius)
    end

    ---Returns true if the coordinate is within the atmosphere of the body
    ---@param coordinate any
    ---@return boolean
    function s:IsInAtmo(coordinate)
        return s:DistanceToAtmo(coordinate) == 0
    end

    ---Returns the distance to the highest possible point on the body or 0 if below higest surface
    ---@param coordinate Vec3
    function s.DistanceToHighestPossibleSurface(coordinate)
        return max(0, (coordinate - s.Geography.Center):len() - s.Geography.Radius - s.Surface.MaxSurfaceAltitude)
    end

    ---Returns a boolean indicating if the coordinate is above sea level and a number representing the absolute distance to the sea level
    ---@param coordinate vec3 The coordinate to get info on.
    ---@return boolean, number
    function s.AboveSeaLevel(coordinate)
        local seaLevel = s.Geography.Radius
        local distanceToCenter = (coordinate - s.Geography.Center):len()
        return distanceToCenter >= seaLevel, abs(distanceToCenter - seaLevel)
    end

    return setmetatable(s, Body)
end

return Body
