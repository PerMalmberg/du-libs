local Vec3 = require("cpml/vec3")
local core = library.getCoreUnit()

---@alias fun3 fun():vec3
---@alias funn fun():number
---@alias funb fun():boolean
---@alias VOrientation { Up:fun3, Right:fun3, Forward:fun3, localized: { Up:fun3, Right:fun3, Forward:fun3 } }
---@alias VMass { Own:funn, MassOfDockedConstructs:funn, MassOfPlayers:funn, Total:funn}
---@alias VVelocity {Angular:fun3, Movement:fun3, localized:{Angular:fun3}}
---@alias VAcceleration {Angular:fun3, Movement:fun3, localized: {Angular:fun3}}
---@alias VPosition {Current:fun3}
---@alias VWorld {AtmoDensity:funn, IsInAtmo:funb, IsInSpace:funb, G:funn, AngularAirFrictionAcceleration:fun3, GravityDirection:fun3}
---@alias VPlayer {position:{Current:fun3, orientation:{Up:fun3}}, camera:{position:{Current:fun3}, orientation:{Forward:fun3, Up:fun3, Right:fun3, IsFirstPerson:funb}}}

---@class Vehicle
---@field orientation VOrientation
---@field mass VMass
---@field velocity VVelocity
---@field acceleration VAcceleration
---@field position VPosition
---@field world VWorld
---@field player VPlayer

local Vehicle = {}
Vehicle.__index = Vehicle
local singleton ---@type Vehicle

local atmoToSpaceDensityLimit = 0.0001 -- At what density level we consider space to begin. Densities higher than this is atmo.

---Creates a new Core
---@return Vehicle
function Vehicle.New()
    if singleton ~= nil then
        return singleton
    end

    singleton = {
        orientation = {
            Up = function()
                -- This points in the current up direction of the vehicle
                return Vec3(construct.getWorldOrientationUp())
            end,
            Right = function()
                -- This points in the current right direction of the vehicle
                return Vec3(construct.getWorldOrientationRight())
            end,
            Forward = function()
                -- This points in the current forward direction of the vehicle
                return Vec3(construct.getWorldOrientationForward())
            end,
            localized = {
                Up = function()
                    return Vec3(construct.getOrientationUp())
                end,
                Right = function()
                    return Vec3(construct.getOrientationRight())
                end,
                Forward = function()
                    return Vec3(construct.getOrientationForward())
                end
            }
        },
        mass = {
            Own = function()
                return construct.getMass()
            end,
            Total = function()
                local m = singleton.mass
                return m.Own() + m.MassOfDockedConstructs() + m.MassOfPlayers()
            end,
            MassOfDockedConstructs = function()
                local mass = 0
                for _, id in ipairs(construct.getDockedConstructs()) do
                    mass = mass + construct.getDockedConstructMass(id)
                end

                return mass
            end,
            MassOfPlayers = function()
                local mass = 0
                for _, id in ipairs(construct.getPlayersOnBoard()) do
                    mass = mass + construct.getBoardedPlayerMass(id)
                end
                return mass
            end
        },
        velocity = {
            Angular = function()
                return Vec3(construct.getWorldAngularVelocity())
            end,
            Movement = function()
                return Vec3(construct.getWorldAbsoluteVelocity())
            end,
            localized = {
                Angular = function()
                    return Vec3(construct.getAngularVelocity())
                end
            }
        },
        acceleration = {
            Angular = function()
                return Vec3(construct.getWorldAngularAcceleration())
            end,
            Movement = function()
                return Vec3(construct.getWorldAcceleration())
            end,
            localized = {
                Angular = function()
                    return Vec3(construct.getAngularAcceleration())
                end
            }
        },
        position = {
            Current = function()
                return Vec3(construct.getWorldPosition())
            end
        },
        world = {
            AtmoDensity = unit.getAtmosphereDensity,
            IsInAtmo = function()
                return unit.getAtmosphereDensity() > atmoToSpaceDensityLimit
            end,
            IsInSpace = function()
                return not singleton.world.IsInAtmo()
            end,
            G = core.getGravityIntensity,
            AngularAirFrictionAcceleration = function()
                return Vec3(construct.getWorldAirFrictionAcceleration())
            end,
            GravityDirection = function()
                return vec3(core.getWorldVertical())
            end
        },
        player = {
            position = {
                Current = function()
                    return Vec3(player.getWorldPosition)
                end
            },
            orientation = {
                Up = function()
                    return Vec3(player.getWorldUp())
                end
            },
            camera = {
                position = {
                    Current = function()
                        return Vec3(system.getCameraWorldPos())
                    end
                },
                orientation = {
                    Forward = function()
                        return Vec3(system.getCameraWorldForward())
                    end,
                    Up = function()
                        return Vec3(system.getCameraWorldUp())
                    end,
                    Right = function()
                        return Vec3(system.getCameraWorldRight())
                    end,
                    IsFirstPerson = system.isFirstPerson
                }
            }
        }
    }

    return singleton
end

return Vehicle
