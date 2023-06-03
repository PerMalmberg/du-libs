local Vec3 = require("math/Vec3")

local solve3 = library.systemResolution3

local atan = math.atan
local cos = math.cos
local max = math.max
local min = math.min
local abs = math.abs
local sqrt = math.sqrt
local deg2rad = math.pi / 180

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

---@param v number
---@return number
calc.Sign = function(v)
    if v > 0 then
        return 1
    elseif v < 0 then
        return -1
    else
        return 0
    end
end

---@param value number
---@param sign integer -1 or 1
---@return number
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

--- @param coordinate Vec3 A position in in world coordinates to convert to local coordinates
calc.WorldToLocal = function(coordinate)
    local localized = coordinate - Vec3.New(construct.getWorldPosition())
    return Vec3.New(solve3(construct.getWorldRight(), construct.getWorldForward(), construct.getWorldUp(),
        { localized:Unpack() }))
end

--- @param direction Vec3 A unit vector, in world coordinates to convert to a local unit vector
calc.WorldDirectionToLocal = function(direction)
    return Vec3.New(solve3(construct.getWorldRight(), construct.getWorldForward(), construct.getWorldUp(),
        { direction:Unpack() }))
end
--[[ This one does the same thing as the above one, except that it doesn't subtract the construct position to move the vector to origo.
calc.WorldToLocal = function(worldPos)
    local RGT = Vec3.New(construct.getWorldRight())
    local FWD = Vec3.New(construct.getWorldForward())
    local UP = Vec3.New(construct.getWorldUp())

    local localPos = Vec3.New(
            worldPos:Dot(RGT),
            worldPos:Dot(FWD),
            worldPos:Dot(UP)
    )

    return localPos
end]]
--
calc.LocalToWorld = function(localCoord)
    local xOffset = localCoord.x * Vec3.New(construct.getWorldOrientationForward())
    local yOffset = localCoord.y * Vec3.New(construct.getWorldOrientationRight())
    local zOffset = localCoord.z * Vec3.New(construct.getWorldOrientationUp())
    return xOffset + yOffset + zOffset + Vec3.New(construct.getWorldPosition())
end

---@param normal Vec3
---@param vecA Vec3
---@param vecB Vec3
---@return number
calc.SignedRotationAngle = function(normal, vecA, vecB)
    vecA = vecA:ProjectOnPlane(normal)
    vecB = vecB:ProjectOnPlane(normal)
    return atan(vecA:Cross(vecB):Dot(normal), vecA:Dot(vecB))
end

---@param up Vec3
---@param right Vec3
---@return Vec3
calc.StraightForward = function(up, right)
    return up:Cross(right)
end

---@param mps number
---@return number
calc.Mps2Kph = function(mps)
    return mps * 3.6
end

---@param kph number
---@return number
calc.Kph2Mps = function(kph)
    return kph / 3.6
end

---Clamps v between minVal and maxVal, inclusive
---@param v number
---@param minVal number
---@param maxVal number
---@return number
calc.Clamp = function(v, minVal, maxVal)
    return min(maxVal, max(v, minVal))
end


---Returns the nearest point on the line
---@param lineStart Vec3
---@param lineDirection Vec3
---@param pointAwayFromLine Vec3
---@return Vec3
calc.NearestPointOnLine = function(lineStart, lineDirection, pointAwayFromLine)
    -- https://forum.unity.com/threads/how-do-i-find-the-closest-point-on-a-line.340058/
    local lineDir = lineDirection:Normalize()
    local v = pointAwayFromLine - lineStart
    local d = v:Dot(lineDir)
    return lineStart + lineDir * d
end

---Gets the closest point to p on the line segment a-b
---@param a Vec3 Line start
---@param b Vec3 Line end
---@param p Vec3 The point away from the line
---@return Vec3 #Point on the line segment
calc.NearestOnLineBetweenPoints = function(a, b, p)
    local ab = b - a
    local ap = p - a

    local proj = ap:Dot(ab)

    local abLen2 = ab:Len2()

    if abLen2 <= 0 then
        -- a and b are on the same place
        return a
    end

    local d = proj / abLen2

    if d <= 0 then
        return a
    elseif d >= 1 then
        return b
    else
        return a + ab * d
    end
end

-- https://gamedev.stackexchange.com/questions/96459/fast-ray-sphere-collision-code
-- https://github.com/excessive/cpml/blob/master/modules/intersect.lua#L152
---@param ray Ray
---@param sphereCenter Vec3
---@param sphereRadius number
---@return boolean,Vec3,number
calc.LineIntersectSphere = function(ray, sphereCenter, sphereRadius)
    local offset = ray.Start - sphereCenter
    local b = offset:Dot(ray.Dir)
    local c = offset:Dot(offset) - sphereRadius * sphereRadius

    -- ray's position outside sphere (c > 0)
    -- ray's direction pointing away from sphere (b > 0)
    if c > 0 and b > 0 then
        return false, Vec3.New(), 0
    end

    local discr = b * b - c

    -- negative discriminant
    if discr < 0 then
        return false, Vec3.New(), 0
    end

    -- If t is negative, ray started inside sphere so clamp t to zero
    local t = -b - sqrt(discr)
    t = t < 0 and 0 or t

    -- Return collision point and distance from ray origin
    return true, ray.Start + ray.Dir * t, t
end

---Determmines of the value is NaN
---@param value number
---@return boolean
calc.IsNaN = function(value)
    return value ~= value
end

---Determines if the difference between a and b is within the margin
---@param a number
---@param b number
---@param margin number
---@return boolean
calc.AreAlmostEqual = function(a, b, margin)
    return abs(a - b) < margin
end

---Tenary function
---@generic T
---@param condition boolean
---@param a T
---@param b T
---@return T
calc.Ternary = function(condition, a, b)
    if condition then
        return a
    end

    return b
end

---Rotate a vector around a point
---@param vector Vec3 The vector to rotate
---@param rotationPoint Vec3 The point to rotate around
---@param degrees number The angle, in degrees, to rotate
---@param axis Vec3 The axis to rotate around
---@return Vec3 #The vector, rotated around the axis
calc.RotateAroundAxis = function(vector, rotationPoint, degrees, axis)
    return (vector - rotationPoint):Rotate(degrees * deg2rad, axis:NormalizeInPlace()) + rotationPoint
end

---@param vector Vec3
---@return number
calc.SignLargestAxis = function(vector)
    local arr = { vector:Unpack() }

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


---Calculates the brake distance
---@param speed number
---@param acceleration number
---@return number
calc.CalcBrakeDistance = function(speed, acceleration)
    local d = (speed ^ 2) / (2 * acceleration)
    if calc.IsNaN(d) or acceleration == 0 then
        return 0
    end

    return d
end

---Calculates the required brake acceleration to come to a stop in the remaining distance
---@param speed number
---@param remainingDistance number
---@return number
calc.CalcBrakeAcceleration = function(speed, remainingDistance)
    ---Calculating the brake acceleration is the same mathematical operation as for the brake distance so we resuse for less code.
    return calc.CalcBrakeDistance(speed, remainingDistance)
end


-- https://github.com/GregLukosek/3DMath/blob/master/Math3D.cs

-- Get the shortest distance between a point and a plane. The output is signed so it holds information
-- as to which side of the plane normal the point is.
---@param planeNormal Vec3
---@param planePoint Vec3
---@param point Vec3
---@return number
local function signedDistancePlanePoint(planeNormal, planePoint, point)
    return planeNormal:Dot(point - planePoint)
end

---Project a point on a plane
---@param planeNormal Vec3
---@param planePoint Vec3
---@param point Vec3
---@return Vec3
calc.ProjectPointOnPlane = function(planeNormal, planePoint, point)
    -- First calculate the distance from the point to the plane:
    local distance = signedDistancePlanePoint(planeNormal, planePoint, point)

    -- Reverse the sign of the distance
    distance = distance * -1;

    -- Get a translation vector
    local translationVector = planeNormal * distance

    -- Translate the point to form a projection
    return point + translationVector
end

calc.AngleToDot = function(angleDegrees)
    return cos(angleDegrees * deg2rad)
end

return calc
