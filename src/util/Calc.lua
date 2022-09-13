local Vec3 = require("cpml/vec3")

local solve3 = library.systemResolution3

local atan = math.atan
local max = math.max
local min = math.min
local abs = math.abs
local deg2rad = math.rad
local sqrt = math.sqrt

local calc = {}

---Returns the absolute difference between a and b
---@param a any Value a to compare
---@param b any Value b to compare
---@return any Absolute difference between the two numbers.
calc.AbsDiff = function(a, b)
    a, b = abs(a), abs(b)
    return max(a, b) - min(a, b)
end

calc.Round = function(number, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
end

calc.Sign = function(v)
    if v > 0 then
        return 1
    elseif v < 0 then
        return -1
    else
        return 0
    end
end

calc.SetSign = function(value, sign)
    value = abs(value)

    if sign ~= 0 then
        return value * sign
    end

    return value
end

calc.Scale = function(value, inMin, inMax, outMin, outMax)
    return (outMax - outMin) / (inMax - inMin) * (value - inMin) + outMin
end

--- @param coordinate vec3 A position in in world coordinates to convert to local coordinates
calc.WorldToLocal = function(coordinate)
    local localized = coordinate - Vec3(construct.getWorldPosition())
    return Vec3(solve3(construct.getWorldRight(), construct.getWorldForward(), construct.getWorldUp(), { localized:unpack() }))
end

--- @param direction vec3 A unit vector, in world coordinates to convert to a local unit vector
calc.WorldDirectionToLocal = function(direction)
    return Vec3(solve3(construct.getWorldRight(), construct.getWorldForward(), construct.getWorldUp(), { direction:unpack() }))
end
--[[ This one does the same thing as the above one, except that it doesn't subtract the construct position to move the vector to origo.
calc.WorldToLocal = function(worldPos)
    local RGT = vec3(construct.getWorldRight())
    local FWD = vec3(construct.getWorldForward())
    local UP = vec3(construct.getWorldUp())

    local localPos = vec3(
            worldPos:dot(RGT),
            worldPos:dot(FWD),
            worldPos:dot(UP)
    )

    return localPos
end]]--
calc.LocalToWorld = function(localCoord)
    local xOffset = localCoord.x * Vec3(construct.getWorldOrientationForward())
    local yOffset = localCoord.y * Vec3(construct.getWorldOrientationRight())
    local zOffset = localCoord.z * Vec3(construct.getWorldOrientationUp())
    return xOffset + yOffset + zOffset + Vec3(construct.getWorldPosition())
end

calc.SignedRotationAngle = function(normal, vecA, vecB)
    vecA = vecA:project_on_plane(normal)
    vecB = vecB:project_on_plane(normal)
    return atan(vecA:cross(vecB):dot(normal), vecA:dot(vecB))
end

calc.StraightForward = function(up, right)
    return up:cross(right)
end

calc.Mps2Kph = function(mps)
    return mps * 3.6
end

calc.Kph2Mps = function(kph)
    return kph / 3.6
end

calc.NearestPointOnLine = function(lineStart, lineDirection, pointAwayFromLine)
    -- https://forum.unity.com/threads/how-do-i-find-the-closest-point-on-a-line.340058/
    local lineDir = lineDirection:normalize()
    local v = pointAwayFromLine - lineStart
    local d = v:dot(lineDir)
    return lineStart + lineDir * d
end

calc.NearestOnLineBetweenPoints = function(startPoint, endPoint, currentPos, ahead)
    local totalDiff = endPoint - startPoint
    local dir = totalDiff:normalize()
    local nearestPoint = calc.NearestPointOnLine(startPoint, dir, currentPos)

    ahead = (ahead or 0)
    local startDiff = nearestPoint - startPoint
    local distanceFromStart = startDiff:len()
    local rabbitDistance = min(distanceFromStart + ahead, totalDiff:len())
    local rabbit = startPoint + dir * rabbitDistance

    if startDiff:normalize():dot(dir) < 0 then
        return { nearest = startPoint, rabbit = rabbit }
    elseif startDiff:len() >= totalDiff:len() then
        return { nearest = endPoint, rabbit = rabbit }
    else
        return { nearest = nearestPoint, rabbit = rabbit }
    end
end

-- https://gamedev.stackexchange.com/questions/96459/fast-ray-sphere-collision-code
-- https://github.com/excessive/cpml/blob/master/modules/intersect.lua#L152
calc.LineIntersectSphere = function(ray, sphereCenter, sphereRadius)
    local offset = ray.Start - sphereCenter
    local b = offset:dot(ray.Dir)
    local c = offset:dot(offset) - sphereRadius * sphereRadius

    -- ray's position outside sphere (c > 0)
    -- ray's direction pointing away from sphere (b > 0)
    if c > 0 and b > 0 then
        return false, nil, nil
    end

    local discr = b * b - c

    -- negative discriminant
    if discr < 0 then
        return false, nil, nil
    end

    -- Clamp t to 0
    local t = -b - sqrt(discr)
    t = t < 0 and 0 or t

    -- Return collision point and distance from ray origin
    return true, ray.Start + ray.Dir * t, t
end

calc.IsNaN = function(value)
    return value ~= value
end

calc.AreAlmostEqual = function(a, b, margin)
    return abs(a - b) < margin
end

calc.Ternary = function(condition, a, b)
    if condition then
        return a
    end

    return b
end

calc.RotateAroundAxis = function(vector, rotationPoint, degrees, axis)
    return (vector - rotationPoint):rotate(deg2rad(degrees), axis:normalize_inplace()) + rotationPoint
end

calc.SignLargestAxis = function(vector)
    local arr = { vector:unpack() }

    local ix = 1
    local maxFound = abs(arr[ix])
    for i = 1, #arr, 1 do
        local v = abs(arr[i])
        if v > maxFound then
            maxFound = v
            ix = i
        end
    end

    return calc.Sign(arr[ix])
end

calc.CalcBrakeDistance = function(speed, acceleration)
    local d = (speed ^ 2) / (2 * acceleration)
    if calc.IsNaN(d) or acceleration == 0 then
        return 0
    end

    return d
end

calc.CalcBrakeAcceleration = function(speed, remainingDistance)
    local d = (speed ^ 2) / (2 * remainingDistance)

    if calc.IsNaN(d) or remainingDistance == 0 then
        return 0
    end

    return d
end


-- https://github.com/GregLukosek/3DMath/blob/master/Math3D.cs

-- Get the shortest distance between a point and a plane. The output is signed so it holds information
-- as to which side of the plane normal the point is.
calc.SignedDistancePlanePoint = function(planeNormal, planePoint, point)
    return planeNormal:dot(point - planePoint);
end

calc.ProjectPointOnPlane = function(planeNormal, planePoint, point)
    -- First calculate the distance from the point to the plane:
    local distance = calc.SignedDistancePlanePoint(planeNormal, planePoint, point)

    -- Reverse the sign of the distance
    distance = distance * -1;

    -- Get a translation vector
    local translationVector = planeNormal * distance

    -- Translate the point to form a projection
    return point + translationVector
end

-- Projects a vector onto a plane. The output is not normalized.
calc.ProjectVectorOnPlane = function(planeNormal, vector)
    return vector - vector:dot(planeNormal) * planeNormal
end

return calc