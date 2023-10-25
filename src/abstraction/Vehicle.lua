local Vec3                    = require("math/Vec3")
local NV3                     = Vec3.New
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

local Vehicle                 = {}
Vehicle.__index               = Vehicle

local atmoToSpaceDensityLimit = 0.0001 -- At what density level we consider space to begin. Densities higher than this is atmo.

local vehicle                 = {
    acceleration = {
        Angular = function()
            return NV3(construct.getWorldAngularAcceleration())
        end,
    },
    player = {
        position = {
            Current = function()
                return NV3(player.getWorldPosition())
            end
        },
        orientation = {
            Up = function()
                return NV3(player.getWorldUp())
            end
        },
    },
}

Current                       = function() return NV3(construct.getWorldPosition()) end
Up                            = function() return NV3(construct.getWorldOrientationUp()) end
Right                         = function() return NV3(construct.getWorldOrientationRight()) end
Forward                       = function() return NV3(construct.getWorldOrientationForward()) end

LocalUp                       = function() return NV3(construct.getOrientationUp()) end
LocalRight                    = function() return NV3(construct.getOrientationRight()) end
LocalForward                  = function() return NV3(construct.getOrientationForward()) end

AtmoDensity                   = unit.getAtmosphereDensity
IsInAtmo                      = function() return AtmoDensity() > atmoToSpaceDensityLimit end
IsInSpace                     = function() return not IsInAtmo() end
GravityDirection              = function() return NV3(core.getWorldVertical()) end
G                             = core.getGravityIntensity
AirFrictionAcceleration       = function() return NV3(construct.getWorldAirFrictionAcceleration()) end

MaxSpeed                      = function()
    if IsInAtmo() then
        return construct.getFrictionBurnSpeed() * 0.99
    end

    return construct.getMaxSpeed()
end

Acceleration                  = function() return NV3(construct.getWorldAcceleration()) end
Velocity                      = function() return NV3(construct.getWorldAbsoluteVelocity()) end
LocalAngVel                   = function() return NV3(construct.getAngularVelocity()) end
LocalAngAcc                   = function() return NV3(construct.getAngularAcceleration()) end

-- player.isFrozen() can return nil, reported to NQ in ticket 81865
-- Their answer is "don't call from flush"
IsFrozen                      = player.isFrozen

TotalMass                     = construct.getTotalMass

return vehicle
