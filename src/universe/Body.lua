-- Body - stellar body

require("system/locale")
local checks = require("debug/Checks")
local Vec3 = require("cpml/vec3")

local max = math.max

---@module "Galaxy"

---@class Body
---@field Galaxy Galaxy The galaxy the body resides in
---@field Id number The body ID
---@field Name string The name of the body
---@field Type string The type of the body
---@field Physics table Physics properties
---@field Geography table Geography properties
---@field Atmosphere table Atmosphere properties
---@field Surface table Surface properties
---@field PvP table Pvp properties
---@field DistanceToAtmo fun(self:Body, point:Vec3):number
---@field IsInAtmo fun(self:Body, point:Vec3):boolean
---@field DistanceToHighestPossibleSurface fun(coordinate:Vec3)

local Body = {}
Body.__index = Body

function Body.New(galaxy, bodyData)
    checks.IsTable(galaxy, "galaxy", "body:Prepare")
    checks.IsTable(bodyData, "data", "body:Prepare")

    local language = LocaleIndex()

    local s = {
        Galaxy = galaxy,
        Id = bodyData.id,
        Name = bodyData.name[language],
        Type = bodyData.type[language],
        Physics = {
            Gravity = bodyData.gravity
        },
        Geography = {
            Center = Vec3(bodyData.center),
            Radius = bodyData.radius,
            MaxSurfaceAltitude = bodyData.surfaceMaxAltitude
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

    ---Returns the distance to the highest possible point on the body or 0 if below lowest surface
    ---@param coordinate Vec3
    function s.DistanceToHighestPossibleSurface(coordinate)
        return max(0, (coordinate - s.Geography.Center):len() - s.Geography.MaxSurfaceAltitude)
    end

    return setmetatable(s, Body)
end

return Body
