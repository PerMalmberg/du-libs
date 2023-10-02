local vehicle              = require("abstraction/Vehicle").New()
local G                    = vehicle.world.G
local calc                 = require("util/Calc")
local universe             = require("universe/Universe").Instance()
local constants            = require("abstraction/Constants")
local TotalMass            = vehicle.mass.Total
local world                = vehicle.world
local Ternary              = calc.Ternary
local IsInAtmo             = world.IsInAtmo
local AtmoDensity          = world.AtmoDensity
local GravityDirection     = world.GravityDirection
local localizedOrientation = vehicle.orientation.localized
local abs                  = math.abs
local min                  = math.min
local mtaa                 = construct.getMaxThrustAlongAxis

local function getLongitudinalForce()
    return mtaa(
        IsInAtmo() and "longitudinal atmospheric_engine" or "longitudinal space_engine",
        { localizedOrientation.Forward():Unpack() })
end

local function getLateralForce()
    return mtaa(IsInAtmo() and "lateral atmospheric_engine" or "lateral space_engine",
        { localizedOrientation.Right():Unpack() })
end

local function getVerticalForce()
    return mtaa(IsInAtmo() and "vertical atmospheric_engine" or "vertical space_engine",
        { localizedOrientation.Up():Unpack() })
end

local function getVerticalHoverForce()
    return mtaa("vertical hover_engine", { localizedOrientation.Up():Unpack() })
end

local function getVerticalBoosterForce()
    return mtaa("vertical booster_engine", { localizedOrientation.Up():Unpack() })
end

local atmoRangeFMaxPlus = 1
local atmoRangeFMaxMinus = 2
local spaceRangeFMaxPlus = 3
local spaceRangeFMaxMinus = 4

---@alias rangeFunc fun():number[]
---@alias rangeFuncArr rangeFunc[]

---@param ranges rangeFunc[] The functions to call to get atmo and space forces. First one should be the regular engines, next hovers and vertical boosters
---@param positive boolean
---@return number
local function getCurrent(ranges, positive)
    local plus, minus
    if world.IsInAtmo() then
        plus = atmoRangeFMaxPlus
        minus = atmoRangeFMaxMinus
    else
        plus = spaceRangeFMaxPlus
        minus = spaceRangeFMaxMinus
    end

    local r = { FMaxPlus = 0, FMaxMinus = 0 }

    for i, range in ipairs(ranges) do
        local curr = range()

        -- Only fallback to secondary ranges if first one doesn't have any force
        r.FMaxPlus = r.FMaxPlus == 0 and curr[plus] or r.FMaxPlus
        r.FMaxMinus = r.FMaxMinus == 0 and curr[minus] or r.FMaxMinus
    end

    return positive and r.FMaxPlus or r.FMaxMinus
end

---@class EngineAbs
---@field Instance fun():EngineAbs
---@field GetMaxPossibleAccelerationInWorldDirectionForPathFollow fun(self:EngineAbs, direction:Vec3, considerAtmoDensity?:boolean):number

local Engine = {}
Engine.__index = Engine
local s

---Gets the Engine instance
---@return EngineAbs
function Engine.Instance()
    if s then
        return s
    end

    s = {}

    ---The maximum acceleration the construct can give without pushing itself more in one direction than the others.
    ---@param direction Vec3 Direction to move
    ---@param considerAtmoDensity? boolean If true, consider atmo influence on engine power
    ---@return number
    function s:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(direction, considerAtmoDensity)
        considerAtmoDensity = Ternary(considerAtmoDensity == nil, false, considerAtmoDensity)

        direction = calc.WorldDirectionToLocal(direction)

        local directionParts = { direction:Unpack() }

        local isRight = directionParts[1] >= 0
        local isForward = directionParts[2] >= 0
        local isUp = directionParts[3] >= 0

        local atmoInfluence = (IsInAtmo() and considerAtmoDensity) and AtmoDensity() or 1

        -- The 'negative' direction returns a negative value so abs() them.
        local rawEnginePower = {
            abs(Ternary(isRight, s:MaxRightwardThrust(), s:MaxLeftwardThrust())),
            abs(Ternary(isForward, s:MaxForwardThrust(), s:MaxBackwardThrust())),
            abs(Ternary(isUp, s:MaxUpwardThrust(), s:MaxDownwardThrust()))
        }

        local totalMass = TotalMass()

        -- Add current gravity influence as force in Newtons, with the correct direction. As the force has a direction
        -- this works for knowing both available acceleration force as well as brake force.
        local gravityForce = calc.WorldDirectionToLocal(GravityDirection()) * G() * totalMass
        local maxForces = { 0, 0, 0 }
        maxForces[1] = rawEnginePower[1] * atmoInfluence +
            gravityForce:Dot(localizedOrientation.Right() * (isRight and 1 or -1))
        maxForces[2] = rawEnginePower[2] * atmoInfluence +
            gravityForce:Dot(localizedOrientation.Forward() * (isForward and 1 or -1))
        maxForces[3] = rawEnginePower[3] * atmoInfluence +
            gravityForce:Dot(localizedOrientation.Up() * (isUp and 1 or -1))

        -- Find the index with the longest part, this is the main direction.
        -- If all are the same then we use the first one as the main direction

        local main = 1
        local longest = abs(directionParts[main])
        for i, v in ipairs(directionParts) do
            v = abs(v)
            if v > longest then
                longest = v
                main = i
            end
        end

        -- Create a vector that represents the desired force if traveling in the main direction
        local desiredVec = direction * maxForces[main]
        -- Unpack it to get the required forces for each axis, in absolute values
        local desiredForces = { abs(desiredVec.x), abs(desiredVec.y), abs(desiredVec.z) }

        -- Start with the known largest force
        local maxThrust = desiredForces[main]

        -- Now check if any of the axes can give less than what is required,
        -- if any is found to be too weak, the one with the least thrust is the limiter.
        for i, available in ipairs(maxForces) do
            local availableCurr = abs(available)
            -- If there's not engine on an axis, then ingore it.
            if rawEnginePower[i] > 0 and availableCurr < desiredForces[i] then
                -- This engine can't deliver the required force
                maxThrust = min(maxThrust, availableCurr)
            end
        end

        -- Return the minimum of the forces divided by the mass to get acceleration.
        -- When space engines kick in, don't consider atmospheric density.
        local density = AtmoDensity()

        -- Remember that this value is the acceleration, m/s2, not how many g:s we can give. To get that, divide by the current world gravity.
        return (density > constants.SPACE_ENGINE_ATMO_DENSITY_CUTOFF and density or 1) * maxThrust / totalMass
    end

    function s:MaxForwardThrust()
        return getCurrent({ getLongitudinalForce }, true)
    end

    function s:MaxBackwardThrust()
        return getCurrent({ getLongitudinalForce }, false)
    end

    function s:MaxRightwardThrust()
        return getCurrent({ getLateralForce }, true)
    end

    function s:MaxLeftwardThrust()
        return getCurrent({ getLateralForce }, false)
    end

    function s:MaxUpwardThrust()
        return getCurrent({ getVerticalForce, getVerticalHoverForce, getVerticalBoosterForce }, true)
    end

    function s:MaxDownwardThrust()
        return getCurrent({ getVerticalForce }, false)
    end

    return setmetatable(s, Engine)
end

return Engine
