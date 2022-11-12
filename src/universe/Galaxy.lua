-- galaxy - utility class to manage the in-game atlas

local checks = require("debug/Checks")
local Body = require("universe/Body")
local calc = require("util/Calc")
local max = math.max

---@class Galaxy
---@field New fun(galaxyId:integer, galaxyAtlas:table):Galaxy
---@field BodyById fun(self:Galaxy, id:integer):Body Gets a body by the id
---@field GetBodyClosestToPosition fun(self:Galaxy, position:Vec3):Body Gets the body closes to the position
---@field BodiesInPath fun(self:Galaxy, path:Ray):Body[] Returns the bodies with which the ray intersects (including atmosphere), sorted by distance, closest first.
---@field Id integer The id of the galaxy

local Galaxy = {}
Galaxy.__index = Galaxy

---Creates a new Galaxy
---@param galaxyId integer The id of the galaxy
---@param galaxyAtlas table The lookup table from the in-game atlas.
---@return Galaxy
function Galaxy.New(galaxyId, galaxyAtlas)
    checks.IsNumber(galaxyId, "galaxyId", "galaxy:new")

    local s = {
        Id = galaxyId
    }

    local body = {} -- Stellar bodies by id

    checks.IsTable(galaxyAtlas, "galaxyAtlas", "galaxy:Prepare")

    for bodyId, bodyData in pairs(galaxyAtlas) do
        body[bodyId] = Body.New(s, bodyData)
    end

    function s:BodyById(id)
        return body[id]
    end

    ---Gets the body closes to the given position
    ---@param position Vec3 position to get closest body for
    ---@return Body The body
    function s:GetBodyClosestToPosition(position)
        checks.IsVec3(position, "position", "galaxy:GetBodyClosestToPosition")
        local closest
        local smallestDistance

        for _, b in pairs(body) do
            local dist = (b.Geography.Center - position):Len()
            if smallestDistance == nil or dist < smallestDistance then
                smallestDistance = dist
                closest = b
            end
        end

        return closest
    end

    --- Gets the bodies the path intersects, sorted by distance, closest first.
    ---@param ray Ray The ray to check for intersecting bodies
    ---@return table A list of bodies that the path intersects
    function s:BodiesInPath(ray)
        checks.IsRay(ray, "ray", "Galaxy:BodiesInPath")

        local res = {}

        local sortFunc = function(a, b)
            return (a.Geography.Center - ray.Start):len2() < (b.Geography.Center - ray.Start):len2()
        end

        for _, b in pairs(body) do
            -- If no atmosphere, then use physical body
            local radius = max(b.Geography.Radius, b.Atmosphere.Radius)
            local intersects, _, _ = calc.LineIntersectSphere(ray, b.Geography.Center, radius)

            if intersects then
                table.insert(res, b)
            end
        end

        table.sort(res, sortFunc)

        return res
    end

    return setmetatable(s, Galaxy)
end

return Galaxy
