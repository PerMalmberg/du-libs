-- galaxy - utility class to manage the in-game atlas

local checks = require("debug/Checks")
local Body = require("universe/Body")
local calc = require("util/Calc")
local max = math.max

local galaxy = {}
galaxy.__index = galaxy

local singleton = nil

local function new(galaxyId)
    checks.IsNumber(galaxyId, "galaxyId", "galaxy:new")
    local instance = {
        Id = galaxyId,
        body = {} -- Stellar bodies by id
    }
    setmetatable(instance, galaxy)

    return instance
end

function galaxy:BodyById(id)
    return self.body[id]
end

---Gets the body closes to the given position
---@param position vec3 position to get closest body for
---@return Body The body
function galaxy:GetBodyClosestToPosition(position)
    checks.IsVec3(position, "position", "galaxy:GetBodyClosestToPosition")
    local closest
    local smallestDistance

    for _, body in pairs(self.body) do
        local dist = (body.Geography.Center - position):len()
        if smallestDistance == nil or dist < smallestDistance then
            smallestDistance = dist
            closest = body
        end
    end

    return closest
end

--- Gets the bodies the path intersects, sorted by distance, closest first.
---@param ray Ray The ray to check for intersecting bodies
---@return table A list of bodies that the path intersects
function galaxy:BodiesInPath(ray)
    checks.IsRay(ray, "ray", "universe:BodiesInPath")

    local res = {}

    local sortFunc = function(a, b)
        return (a.Geography.Center - ray.Start):len2() < (b.Geography.Center - ray.Start):len2()
    end

    for _, body in pairs(self.body) do
        -- If no atmosphere, then use physical body
        local radius = max(body.Geography.Radius, body.Atmosphere.Radius)
        local intersects, _, _ = calc.LineIntersectSphere(ray, body.Geography.Center, radius)

        if intersects then
            table.insert(res, body)
        end
    end

    table.sort(res, sortFunc)

    return res
end

function galaxy:Prepare(galaxyAtlas)
    checks.IsTable(galaxyAtlas, "galaxyAtlas", "galaxy:Prepare")

    for bodyId, bodyData in pairs(galaxyAtlas) do
        self.body[bodyId] = Body(self, bodyData)
    end
end

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                if singleton == nil then
                    local galaxyId, galaxyAtlas = table.unpack({ ... })
                    singleton = new(galaxyId)
                    singleton:Prepare(galaxyAtlas)
                end
                return singleton
            end
        }
)