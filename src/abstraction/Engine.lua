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
---@field GetAvailableThrust fun(reduceMode:boolean, direction:Vec3, considerAtmoDensity?:boolean):number

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
    ---@param reduceMode boolean If true, returns the available thust while taking the weaker engines into account
    ---@param direction Vec3 Direction to move
    ---@param considerAtmoDensity? boolean If true, consider atmo influence on engine power
    ---@return number # Avaliable acceleration
    function s.GetAvailableThrust(reduceMode, direction, considerAtmoDensity)
        if direction:IsZero() then
            return 0
        end

        direction = calc.WorldDirectionToLocal(direction)
        local totalMass = TotalMass()

        -- Add current gravity influence as force in Newtons

        local gravDir = calc.WorldDirectionToLocal(GravityDirection())

        local gravityForce = Vec3.zero
        if gravDir:Dot(direction) > 0 then
            -- Moving towards gravity, consider it as an engine.
            -- Note to self: Don't add gravity if not travling along it, that will reduce reported available engine force.
            gravityForce = gravDir * G() * totalMass
        end

        -- Setup engines using the thrust for the direction they make the construct move (i.e. oposite to thrust direction)
        ---@alias ThrustAndDir { dir:Vec3, thrust:number }
        ---@type ThrustAndDir
        local engines = {
            { dir = -LocalRight(),   thrust = abs(s:MaxLeftwardThrust()) },
            { dir = LocalRight(),    thrust = abs(s:MaxRightwardThrust()) },
            { dir = -LocalUp(),      thrust = abs(s:MaxDownwardThrust()) },
            { dir = LocalUp(),       thrust = abs(s:MaxUpwardThrust()) },
            { dir = -LocalForward(), thrust = abs(s:MaxBackwardThrust()) },
            { dir = LocalForward(),  thrust = abs(s:MaxForwardThrust()) }
        }

        -- Find engines that contribute to the movement in the direction
        local minThrust = math.huge
        local mainEngine = nil ---@type ThrustAndDir|nil

        for _, engine in ipairs(engines) do
            local dot = engine.dir:Dot(direction)
            -- Compare with a near-zero value for dot as we get values like 1e-11 which are still > 0 but too small to use.
            if dot > 0.001 and engine.thrust > 0.01 then
                -- Calculate the thrust this engine can give for the direction and add the gravity force
                local thrust = dot * engine.thrust + gravityForce:Dot(engine.dir)

                if thrust < minThrust then
                    minThrust = thrust
                end

                -- Find "main" engine closest to direction
                if not mainEngine then
                    mainEngine = engine
                elseif engine.dir:AngleTo(direction) < mainEngine.dir:AngleTo(direction) then
                    mainEngine = engine
                end
            end
        end

        -- No engine?
        if not mainEngine then
            return 0
        end

        local availableForce = mainEngine.thrust

        -- Should we limit thrust to weaker engine?
        if reduceMode and mainEngine.dir:AngleToDeg(direction) > 10 then
            -- Closest engine is outside limit so limit to weakest
            availableForce = minThrust
        end

        local availableThrust = direction * availableForce

        -- When space engines kick in, don't consider atmospheric density.
        if considerAtmoDensity and IsInAtmo() then
            availableThrust = availableThrust * AtmoDensity()
        end

        -- Remember that this value is the acceleration, m/s2, not how many g:s we can give. To get that, divide by the current world gravity.
        return availableThrust:Len() / totalMass
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
