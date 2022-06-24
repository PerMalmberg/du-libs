local library = require("abstraction/Library")()
local construct = require("abstraction/Construct")()
local EngineGroup = require("abstraction/EngineGroup")
local core = library:GetCoreUnit()
local mass = construct.mass
local world = construct.world

local longitudinalEngines = EngineGroup("longitudal")
local lateralEngines = EngineGroup("lateral")
local longLatEngines = EngineGroup("longitudinal", "lateral")
local verticalEngines = EngineGroup("vertical")
local thrustEngines = EngineGroup("thrust")

local longitudalForce = core.getMaxKinematicsParametersAlongAxis(longitudinalEngines:Intersection(), { construct.orientation.localized.Forward():unpack() })
local lateralForce = core.getMaxKinematicsParametersAlongAxis(lateralEngines:Intersection(), { construct.orientation.localized.Right():unpack() })
local verticalForce = core.getMaxKinematicsParametersAlongAxis(verticalEngines:Intersection(), { construct.orientation.localized.Up():unpack() })

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
        r = range.atmoRange
    else
        r = range.spaceRange
    end

    if positive then
        return r.FMaxPlus / mass.Total()
    else
        return r.FMaxMinus / mass.Total()
    end
end

function engine:MaxForce(engineGroup, axis, positive)
    local f = core.getMaxKinematicsParametersAlongAxis(engineGroup:Intersection(), { axis:unpack() })
    return getCurrent(f, positive)
end

function engine:MaxAcceleration(engineGroup, axis, positive)
    return self:MaxForce(engineGroup, axis, positive) / mass.Total()
end

function engine:GetMaxAccelerationAlongAxis(axis)
    -- Until we figure this one out, just return a large value
    return 15
end

function engine:MaxForwardAcceleration()
    return getCurrent(longitudalForce, true)
end

function engine:MaxBackwardAcceleration()
    return getCurrent(longitudalForce, false)
end

function engine:MaxRightwardAcceleration()
    return getCurrent(lateralForce, true)
end

function engine:MaxLeftwardAcceleration()
    return getCurrent(lateralForce, false)
end

function engine:MaxUpwardAcceleration()
    return getCurrent(verticalForce, true)
end

function engine:MaxDownwardAcceleration()
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