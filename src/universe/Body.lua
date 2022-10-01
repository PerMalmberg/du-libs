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
---@field DistanceToAtmo fun(self:Body, point:Vec3):number Returns the distance to atmo, or 0 if already in atmo.
---@field IsInAtmo fun(self:Body, point:Vec3):boolean Returns true if the point is within the atmosphere of the body.

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
            Radius = bodyData.radius
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

    function s:DistanceToAtmo(from)
        return max(0, (from - s.Geography.Center):len() - s.Atmosphere.Radius)
    end

    function s:IsInAtmo(point)
        return s:DistanceToAtmo(point) == 0
    end

    return setmetatable(s, Body)
end

return Body
