require("abstraction/Vehicle")
local calc      = require("util/Calc")
local constants = require("abstraction/Constants")
local Ternary   = calc.Ternary
local abs       = math.abs
local min       = math.min
local mtaa      = construct.getMaxThrustAlongAxis

local function getLongitudinalForce()
    return mtaa(
        IsInAtmo() and "longitudinal atmospheric_engine" or "longitudinal space_engine",
        { LocalForward():Unpack() })
end

local function getLateralForce()
    return mtaa(IsInAtmo() and "lateral atmospheric_engine" or "lateral space_engine",
        { LocalRight():Unpack() })
end

local function getVerticalForce()
    return mtaa(IsInAtmo() and "vertical atmospheric_engine" or "vertical space_engine",
        { LocalUp():Unpack() })
end

local function getVerticalHoverForce()
    return mtaa("vertical hover_engine", { LocalUp():Unpack() })
end

local function getVerticalBoosterForce()
    return mtaa("vertical booster_engine", { LocalUp():Unpack() })
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
    if IsInAtmo() then
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
    ---@return number # Avaliable acceleration
    function s:GetMaxPossibleAccelerationInWorldDirectionForPathFollow(direction, considerAtmoDensity)
        considerAtmoDensity = Ternary(considerAtmoDensity == nil, false, considerAtmoDensity)

        direction = calc.WorldDirectionToLocal(direction)

        local isRight = direction.x >= 0
        local isForward = direction.y >= 0
        local isUp = direction.z >= 0

        local atmoInfluence = (IsInAtmo() and considerAtmoDensity) and AtmoDensity() or 1

        local rawEnginePower = Vec3.New(
            Ternary(isRight, s:MaxRightwardThrust(), s:MaxLeftwardThrust()),
            Ternary(isForward, s:MaxForwardThrust(), s:MaxBackwardThrust()),
            Ternary(isUp, s:MaxUpwardThrust(), s:MaxDownwardThrust()))

        local totalMass = TotalMass()

        -- Add current gravity influence as force in Newtons, to get available engine force
        local gravityForce = calc.WorldDirectionToLocal(GravityDirection()) * G() * totalMass
        local maxForces = rawEnginePower * atmoInfluence + gravityForce

        if direction:IsZero() then
            return 0
        else
            -- Based on how aligned we are to the direction, opt to limit acceleration
            local availableForce = maxForces:Dot(direction)

            -- When space engines kick in, don't consider atmospheric density.
            local density = AtmoDensity()

            -- Remember that this value is the acceleration, m/s2, not how many g:s we can give. To get that, divide by the current world gravity.
            return (density > constants.SPACE_ENGINE_ATMO_DENSITY_CUTOFF and density or 1) * availableForce / totalMass
        end
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
