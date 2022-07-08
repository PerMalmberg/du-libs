local library = require("abstraction/Library")()
local Vec3 = require("cpml/vec3")

local core = library:GetCoreUnit()
local solve3 = library:GetSolver3()

local atan = math.atan
local max = math.max
local min = math.min
local abs = math.abs

local calc = {
    ---Returns the absolute difference between a and b
    ---@param a any Value a to compare
    ---@param b any Value b to compare
    ---@return any Absolute difference between the two numbers.
    AbsDiff = function(a, b)
        a, b = abs(a), abs(b)
        return max(a, b) - min(a, b)
    end,
    Round = function(number, decimalPlaces)
        local mult = 10 ^ (decimalPlaces or 0)
        return math.floor(number * mult + 0.5) / mult
    end,
    Sign = function(v)
        if v > 0 then
            return 1
        elseif v < 0 then
            return -1
        else
            return 0
        end
    end,
    Scale = function(value, inMin, inMax, outMin, outMax)
        return (outMax - outMin) / (inMax - inMin) * (value - inMin) + outMin
    end,
    --- @param coordinate vec3 A position in in world coordinates to convert to local coordinates
    WorldToLocal = function(coordinate)
        local localized = coordinate - Vec3(construct.getWorldPosition())
        return Vec3(solve3(construct.getWorldRight(), construct.getWorldForward(), construct.getWorldUp(), { localized:unpack() }))
    end,
    --- @param direction vec3 A unit vector, in world coordinates to convert to a local unit vector
    WorldDirectionToLocal = function(direction)
        return Vec3(solve3(construct.getWorldRight(), construct.getWorldForward(), construct.getWorldUp(), { direction:unpack() }))
    end,
    --[[ This one does the same thing as the above one, except that it doesn't subtract the construct position to move the vector to origo.
    WorldToLocal = function(worldPos)
        local RGT = vec3(construct.getWorldRight())
        local FWD = vec3(construct.getWorldForward())
        local UP = vec3(construct.getWorldUp())

        local localPos = vec3(
                worldPos:dot(RGT),
                worldPos:dot(FWD),
                worldPos:dot(UP)
        )

        return localPos
    end,]]--
    LocalToWorld = function(localCoord)
        local xOffset = localCoord.x * Vec3(construct.getWorldOrientationForward())
        local yOffset = localCoord.y * Vec3(construct.getWorldOrientationRight())
        local zOffset = localCoord.z * Vec3(construct.getWorldOrientationUp())
        return xOffset + yOffset + zOffset + Vec3(construct.getWorldPosition())
    end,
    SignedRotationAngle = function(normal, vecA, vecB)
        vecA = vecA:project_on_plane(normal)
        vecB = vecB:project_on_plane(normal)
        return atan(vecA:cross(vecB):dot(normal), vecA:dot(vecB))
    end,
    StraightForward = function(up, right)
        return up:cross(right)
    end,
    Mps2Kph = function(mps)
        return mps * 3.6
    end,
    Kph2Mps = function(kph)
        return kph / 3.6
    end,
    NearestPointOnLine = function(lineStart, lineDirection, pointAwayFromLine)
        -- https://forum.unity.com/threads/how-do-i-find-the-closest-point-on-a-line.340058/
        local lineDir = lineDirection:normalize()
        local v = pointAwayFromLine - lineStart
        local d = v:dot(lineDir)
        return lineStart + lineDir * d
    end,
    IsNaN = function(value)
        return value ~= value
    end,
    AreAlmostEqual = function(a, b, margin)
        return abs(a - b) < margin
    end,
    Ternary = function(condition, a, b)
        if condition then
            return a
        end

        return b
    end
}

return calc