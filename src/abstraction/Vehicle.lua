local V3                      = require("math/Vec3").New
local core                    = library.getCoreUnit()

---@alias fun3 fun():Vec3
---@alias funn fun():number
---@alias funb fun():boolean
---@alias VPosition {Current:fun3}
---@alias VPlayer {position:{Current:fun3, orientation:{Forward:fun3, Up:fun3, Right:fun3, IsFirstPerson:funb}}}}
---@alias VSpeed {MaxSpeed:funn}

---@class Vehicle
---@field position VPosition
---@field player VPlayer
---@field speed VSpeed

local ct                      = construct

local Vehicle                 = {}
Vehicle.__index               = Vehicle

local atmoToSpaceDensityLimit = 0.0001 -- At what density level we consider space to begin. Densities higher than this is atmo.

local vehicle                 = {
    acceleration = {
        Angular = function()
            return V3(ct.getWorldAngularAcceleration())
        end,
    },
    player = {
        position = {
            Current = function()
                return V3(player.getWorldPosition())
            end
        },
        orientation = {
            Up = function()
                return V3(player.getWorldUp())
            end
        },
    },
}

Current                       = function() return V3(ct.getWorldPosition()) end
Up                            = function() return V3(ct.getWorldOrientationUp()) end
Right                         = function() return V3(ct.getWorldOrientationRight()) end
Forward                       = function() return V3(ct.getWorldOrientationForward()) end

LocalUp                       = function() return V3(ct.getOrientationUp()) end
LocalRight                    = function() return V3(ct.getOrientationRight()) end
LocalForward                  = function() return V3(ct.getOrientationForward()) end

AtmoDensity                   = unit.getAtmosphereDensity
IsInAtmo                      = function() return AtmoDensity() > atmoToSpaceDensityLimit end
IsInSpace                     = function() return not IsInAtmo() end
GravityDirection              = function() return V3(core.getWorldVertical()) end
G                             = core.getGravityIntensity
AirFrictionAcceleration       = function() return V3(ct.getWorldAirFrictionAcceleration()) end

MaxSpeed                      = function()
    return IsInAtmo() and ct.getFrictionBurnSpeed() * 0.99 or ct.getMaxSpeed()
end

Acceleration                  = function() return V3(ct.getWorldAcceleration()) end
Velocity                      = function() return V3(ct.getWorldAbsoluteVelocity()) end
LocalAngVel                   = function() return V3(ct.getAngularVelocity()) end
LocalAngAcc                   = function() return V3(ct.getAngularAcceleration()) end

-- player.isFrozen() can return nil, reported to NQ in ticket 81865
-- Their answer is "don't call from flush"
IsFrozen                      = player.isFrozen

TotalMass                     = ct.getTotalMass

return vehicle
