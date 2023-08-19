local vehicle = require("abstraction/Vehicle").New()
local G = vehicle.world.G
local EngineGroup = require("abstraction/EngineGroup")
local calc = require("util/Calc")
local universe = require("universe/Universe").Instance()
local constants = require("abstraction/Constants")
local mass = vehicle.mass
local world = vehicle.world
local Ternary = calc.Ternary
local IsInAtmo = world.IsInAtmo
local localizedOrientation = vehicle.orientation.localized
local abs = math.abs
local min = math.min

local longitudinalAtmoEngines = EngineGroup.New("longitudinal", "atmospheric_engine")
local longitudinalSpaceEngines = EngineGroup.New("longitudinal", "space_engine")
local lateralAtmoEngines = EngineGroup.New("lateral", "atmospheric_engine")
local lateralSpaceEngines = EngineGroup.New("lateral", "space_engine")
local verticalAtmoEngines = EngineGroup.New("vertical", "atmospheric_engine")
local verticalSpaceEngines = EngineGroup.New("vertical", "space_engine")

local function getLongitudinalForce()
    return construct.getMaxThrustAlongAxis(Ternary(IsInAtmo(), longitudinalAtmoEngines, longitudinalSpaceEngines).
    Intersection(), { localizedOrientation.Forward():Unpack() })
end

local function getLateralForce()
    return construct.getMaxThrustAlongAxis(Ternary(IsInAtmo(), lateralAtmoEngines, lateralSpaceEngines).Intersection(),
        { localizedOrientation.Right():Unpack() })
end

local function getVerticalForce()
    return construct.getMaxThrustAlongAxis(Ternary(IsInAtmo(), verticalAtmoEngines, verticalSpaceEngines).Intersection()
    , { localizedOrientation.Up():Unpack() })
end

local atmoRangeFMaxPlus = 1
local atmoRangeFMaxMinus = 2
local spaceRangeFMaxPlus = 3
local spaceRangeFMaxMinus = 4

---@param range number[]
---@param positive boolean
---@return number
local function getCurrent(range, positive)
    local r

    if world.IsInAtmo() then
        r = { FMaxPlus = range[atmoRangeFMaxPlus], FMaxMinus = range[atmoRangeFMaxMinus] }
    else
        r = { FMaxPlus = range[spaceRangeFMaxPlus], FMaxMinus = range[spaceRangeFMaxMinus] }
    end

    return calc.Ternary(positive, r.FMaxPlus, r.FMaxMinus)
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

    function s:MaxForce(engineGroup, axis, positive)
        local f = construct.getMaxThrustAlongAxis(engineGroup.Intersection(), { axis:Unpack() })
        return getCurrent(f, positive)
    end

    function s:MaxAcceleration(engineGroup, axis, positive)
        return self:MaxForce(engineGroup, axis, positive) / mass.Total()
    end

    ---The maximum acceleration the construct can give without pushing itself more in one direction than the others.
    ---@param direction Vec3 Direction to move
    ---@param considerAtmoDensity? boolean If true, consider atmo influence on engine power
    ---@return number
    function s:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(direction, considerAtmoDensity)
        considerAtmoDensity = Ternary(considerAtmoDensity == nil, false, considerAtmoDensity)

        -- Convert world direction to local (need to add position since the function subtracts that.
        direction = calc.WorldDirectionToLocal(direction)

        local directionParts = { direction:Unpack() }

        local isRight = directionParts[1] >= 0
        local isForward = directionParts[2] >= 0
        local isUp = directionParts[3] >= 0

        local atmoInfluence = Ternary(world.IsInAtmo() and considerAtmoDensity, world.AtmoDensity(), 1)

        -- The 'negative' direction returns a negative value so abs() them.
        local maxForces = {
            abs(Ternary(isRight, self:MaxRightwardThrust(), self:MaxLeftwardThrust())) * atmoInfluence,
            abs(Ternary(isForward, self:MaxForwardThrust(), self:MaxBackwardThrust())) * atmoInfluence,
            abs(Ternary(isUp, self:MaxUpwardThrust(), self:MaxDownwardThrust())) * atmoInfluence
        }

        local totalMass = mass.Total()

        -- Add current gravity influence as force in Newtons, with the correct direction. As the force has a direction
        -- this works for knowing both available acceleration force as well as brake force.
        local gravityForce = calc.WorldDirectionToLocal(universe:VerticalReferenceVector()) * G() * totalMass
        maxForces[1] = maxForces[1] + gravityForce:Dot(localizedOrientation.Right() * calc.Ternary(isRight, 1, -1))
        maxForces[2] = maxForces[2] + gravityForce:Dot(localizedOrientation.Forward() * calc.Ternary(isForward, 1, -1))
        maxForces[3] = maxForces[3] + gravityForce:Dot(localizedOrientation.Up() * calc.Ternary(isUp, 1, -1))

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

        -- Create a vector that represents the max force of the main direction, Unpack it to
        -- get the required forces for each axis, in absolute values
        local maxVec = maxForces[main] * direction
        local requiredForces = { abs(maxVec.x), abs(maxVec.y), abs(maxVec.z) }

        -- Start with the known largest force
        local maxThrust = requiredForces[main]

        -- Now check if any of the axes can give less than what is required,
        -- if any is found to be too weak, the one with the least thrust is the limiter.
        for i, required in ipairs(requiredForces) do
            if required > maxForces[i] then
                -- This engine can't deliver the required force
                maxThrust = min(maxThrust, maxForces[i])
            end
        end

        -- Return the minimum of the forces divided by the mass to get acceleration.
        -- When space engines kick in, don't consider atmospheric density.
        local density = world.AtmoDensity()

        -- Remember that this value is the acceleration, m/s2, not how many g:s we can give. To get that, divide by the current world gravity.
        return (density > constants.SPACE_ENGINE_ATMO_DENSITY_CUTOFF and density or 1) * maxThrust / totalMass
    end

    function s:MaxForwardThrust()
        return getCurrent(getLongitudinalForce(), true)
    end

    function s:MaxBackwardThrust()
        return getCurrent(getLongitudinalForce(), false)
    end

    function s:MaxRightwardThrust()
        return getCurrent(getLateralForce(), true)
    end

    function s:MaxLeftwardThrust()
        return getCurrent(getLateralForce(), false)
    end

    function s:MaxUpwardThrust()
        return getCurrent(getVerticalForce(), true)
    end

    function s:MaxDownwardThrust()
        return getCurrent(getVerticalForce(), false)
    end

    return setmetatable(s, Engine)
end

return Engine
