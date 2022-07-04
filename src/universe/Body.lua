-- Body - stellar bodies

local checks = require("debug/Checks")
local Vec3 = require("cpml/vec3")
local ENGLISH = 1

local body = {}
body.__index = body

local function new()
    local instance = {}
    setmetatable(instance, body)

    return instance
end

function body:Prepare(galaxy, data)
    checks.IsTable(galaxy, "galaxy", "body:Prepare")
    checks.IsTable(data, "data", "body:Prepare")

    self.Galaxy = galaxy
    self.Id = data.id
    self.Name = data.name[ENGLISH]
    self.Type = data.type[ENGLISH]

    self.Physics = {
        Gravity = data.gravity
    }
    self.Geography = {
        Center = Vec3(data.center),
        Radius = data.radius
    }
    self.Atmosphere = {
        Present = data.hasAtmosphere,
        Thickness = data.atmosphereThickness,
        Radius = data.atmosphereRadius
    }
    self.Surface = {
        MaxAltitude = data.surfaceMaxAltitude,
        MinAltitude = data.surfaceMinAltitude
    }
    self.Pvp = {
        LocatedInSafeZone = data.isInSafeZone
    }

end

function body:__tostring()
    return self.Name
end

function body:IsWithinAtmosphere(position)
    local distanceToCenter = (position - self.Geography.Center):len()
    return distanceToCenter < self.Atmosphere.Radius
end

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                local b = new()
                b:Prepare(...)
                return b
            end
        }
)