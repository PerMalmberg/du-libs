-- Universe - utility class to manage the in-game atlas
local log = require("debug/Log").Instance()
local Galaxy = require("universe/Galaxy")
local Position = require("universe/Position")
local Vec3 = require("math/Vec3")
local cos = math.cos
local sin = math.sin

local stringMatch = string.match
local numberPattern = " *([+-]?%d+%.?%d*e?[+-]?%d*)"
local posPattern = "::pos{" ..
    numberPattern .. "," .. numberPattern .. "," .. numberPattern .. "," .. numberPattern .. "," .. numberPattern .. "}"

---@class Universe
---@field Instance fun():Universe
---@field CurrentGalaxyId fun():integer Gets the current galaxy id
---@field CurrentGalaxy fun():Galaxy Gets the current galaxy
---@field ParsePosition fun(pos:string):Position|nil Parses the ::pos{} string and returns a Position or nil.
---@field CreatePos fun(coordinate:Vec3):Position
---@field ClosestBody fun(scoordinate:Vec3):Body Returns the closest body to the given coordinate
---@field VerticalReferenceVector fun():Vec3
local Universe = {}
Universe.__index = Universe

local singleton = nil

function Universe.Instance()
    if singleton then
        return singleton
    end

    local galaxy = {} -- Galaxies by id
    local core = library.getCoreUnit()

    local s = {}

    local duAtlas = require("atlas")

    if type(duAtlas) ~= "table" then
        error("Invalid atlas")
        unit.exit()
    end

    for galaxyId, galaxyData in pairs(duAtlas) do
        galaxy[galaxyId] = Galaxy.New(galaxyId, galaxyData)
    end

    ---Gets the current galaxy id
    ---@return number The id of the current galaxy
    function s.CurrentGalaxyId()
        return 0 -- Until there are more than one galaxy in the game.
    end

    ---Gets the current galaxy
    ---@return Galaxy The current galaxy
    function s.CurrentGalaxy()
        return galaxy[s.CurrentGalaxyId()]
    end

    ---Parses a position string
    ---@param pos string The "::pos{...}" string
    ---@return Position|nil A position in space or on a planet
    function s.ParsePosition(pos)
        local x, y, z, bodyRef
        local galaxyId, bodyId, latitude, longitude, altitude = stringMatch(pos, posPattern)

        if galaxyId ~= nil then
            galaxyId = tonumber(galaxyId)
            bodyId = tonumber(bodyId)

            --[[Positions in space, such as asteroids have no bodyId id. In this case
            latitude, longitude, altitude are x, y, z in meters.

            In either case, the closest stellar body is set as the positions body.
            ]]
            if bodyId == 0 then
                x = tonumber(latitude)
                y = tonumber(longitude)
                z = tonumber(altitude)
                local coordinate = Vec3.New(x, y, z)
                bodyRef = s.CurrentGalaxy():GetBodyClosestToPosition(coordinate)
                return Position.New(galaxy[galaxyId], bodyRef, coordinate)
            else
                -- https://stackoverflow.com/questions/1185408/converting-from-longitude-latitude-to-cartesian-coordinates
                -- The x-axis goes through long,lat (0,0), so longitude 0 meets the equator
                -- The y-axis goes through (0,90)
                -- and the z-axis goes through the poles.
                -- Positions on a body have lat, long in degrees and altitude in meters
                latitude = math.rad(latitude)
                longitude = math.rad(longitude)
                local body = galaxy[galaxyId]:BodyById(bodyId)

                local radius = body.Geography.Radius + altitude
                local cosLat = cos(latitude)
                local position = Vec3.New(radius * cosLat * cos(longitude), radius * cosLat * sin(longitude),
                    radius * sin(latitude))
                position = position + body.Geography.Center

                return Position.New(galaxy[galaxyId], body, position)
            end
        end

        log.Error("Invalid position string: ", pos)

        return nil
    end

    ---comment Creates a :Position from the given coordinate, within the current galaxy.
    ---@param coordinate Vec3 The coordinate to create the position for
    ---@return Position
    function s.CreatePos(coordinate)
        local closestBody = s.ClosestBody(coordinate)
        local p = Position.New(s.CurrentGalaxy(), closestBody, coordinate)
        return p
    end

    --- Gets the information for the closest stellar body
    ---@param coordinate Vec3 The coordinate to get the closest body for
    ---@return Body #The Body
    function s.ClosestBody(coordinate)
        local g = s.CurrentGalaxy()
        return g:GetBodyClosestToPosition(coordinate)
    end

    ---Returns a unit vector pointing towards the center of the closest 'gravity well', i.e. planet or space construct.
    --- @return Vec3
    function s.VerticalReferenceVector()
        local worldGrav = Vec3.New(core.getWorldGravity())
        local wDir, wLen = worldGrav:NormalizeLen()
        if wLen == 0 then
            local position = Vec3.New(construct.getWorldPosition())
            local body = s.ClosestBody(position)
            return (body.Geography.Center - position):Normalize()
        else
            return wDir
        end
    end

    singleton = setmetatable(s, Universe)
    return singleton
end

return Universe
