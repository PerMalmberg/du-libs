local vehicle = require("abstraction/Vehicle")()
local EngineGroup = require("abstraction/EngineGroup")
local calc = require("util/Calc")
local log = require("du-libs:debug/Log")()
local mass = vehicle.mass
local world = vehicle.world
local Ternary = calc.Ternary
local abs = math.abs
local min = math.min

local longitudinalEngines = EngineGroup("longitudinal", "thrust")
local lateralEngines = EngineGroup("lateral", "thrust")
local longLatEngines = EngineGroup("longitudinal", "lateral", "thrust")
local verticalEngines = EngineGroup("vertical", "thrust")
local thrustEngines = EngineGroup("thrust")

local longitudalForce = construct.getMaxThrustAlongAxis(longitudinalEngines:Intersection(), { vehicle.orientation.localized.Forward():unpack() })
local lateralForce = construct.getMaxThrustAlongAxis(lateralEngines:Intersection(), { vehicle.orientation.localized.Right():unpack() })
local verticalForce = construct.getMaxThrustAlongAxis(verticalEngines:Intersection(), { vehicle.orientation.localized.Up():unpack() })

local atmoRangeFMaxPlus = 1
local atmoRangeFMaxMinus = 2
local spaceRangeFMaxPlus = 3
local spaceRangeFMaxMinus = 4

local engine = {}
engine.__index = engine

local function new()
    local instance = {}

    setmetatable(instance, engine)

    return instance
end

local function getCurrent(range, positive)
    local r

    if world.IsInAtmo() then
        r = { FMaxPlus = range[atmoRangeFMaxPlus], FMaxMinus = range[atmoRangeFMaxMinus] }
    else
        r = { FMaxPlus = range[spaceRangeFMaxPlus], FMaxMinus = range[spaceRangeFMaxMinus] }
    end

    return calc.Ternary(positive, r.FMaxPlus, r.FMaxMinus)
end

function engine:MaxForce(engineGroup, axis, positive)
    local f = construct.getMaxThrustAlongAxis(engineGroup:Intersection(), { axis:unpack() })
    return getCurrent(f, positive)
end

function engine:MaxAcceleration(engineGroup, axis, positive)
    return self:MaxForce(engineGroup, axis, positive) / mass.Total()
end

function engine:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(direction)
    -- Convert world direction to local (need to add position since the function subtracts that.
    direction = calc.WorldToLocal(direction + vehicle.position.Current())

    local directionParts = { direction:unpack() }

    -- The 'negative' direction returns a negative value so abs() them.
    local maxForces = {
        abs(Ternary(directionParts[1] >= 0, self:MaxRightwardThrust(), self:MaxLeftwardThrust())),
        abs(Ternary(directionParts[2] >= 0, self:MaxForwardThrust(), self:MaxBackwardThrust())),
        abs(Ternary(directionParts[3] >= 0, self:MaxUpwardThrust(), self:MaxDownwardThrust()))
    }

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

    log:Info("Main ", main)

    -- Create a vector that represents the max force of the main direction, unpack it to
    -- get the required forces for each axis, in absolute values
    local maxVec = maxForces[main] * direction
    local requiredForces = { abs(maxVec.x), abs(maxVec.y), abs(maxVec.z) }

    log:Info("req", requiredForces[1], requiredForces[2], requiredForces[3])

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
    -- Remember that this value is the acceleration, m/s2, not how many g:s we can give. To get that, divide by the current world gravity.
    return maxThrust / mass.Total()

    -- QQQ How do we handle downwards direction? Do we the gravity? Can we fill in with gravity in the maxForces above?
end

function engine:MaxForwardThrust()
    return getCurrent(longitudalForce, true)
end

function engine:MaxBackwardThrust()
    return getCurrent(longitudalForce, false)
end

function engine:MaxRightwardThrust()
    return getCurrent(lateralForce, true)
end

function engine:MaxLeftwardThrust()
    return getCurrent(lateralForce, false)
end

function engine:MaxUpwardThrust()
    return getCurrent(verticalForce, true)
end

function engine:MaxDownwardThrust()
    return getCurrent(verticalForce, false)
end

local singleton

-- The module
return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                if singleton == nil then
                    singleton = new()
                end
                return singleton
            end
        }
)