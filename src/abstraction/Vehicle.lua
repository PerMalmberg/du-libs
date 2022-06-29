local library = require("abstraction/Library")()
local Vec3 = require("cpml/vec3")
local core = library:GetCoreUnit()
local ctrl = library:GetController()

local vehicle = {}
vehicle.__index = vehicle
local singleton = nil

local atmoToSpaceDensityLimit = 0.0001 -- At what density level we consider space to begin. Densities higher than this is atmo.


---Creates a new Core
---@return table A new AxisControl
local function new()
    local instance = {
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
            AlongGravity = function()
                -- This points towards the center of the planet, i.e. downwards. Is zero when in space.
                return Vec3(core.getWorldVertical())
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
                return Vec3(core.getWorldAngularAcceleration())
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
            AtmoDensity = ctrl.getAtmosphereDensity,
            IsInAtmo = function()
                return ctrl.getAtmosphereDensity() > atmoToSpaceDensityLimit
            end,
            IsInSpace = function()
                return not singleton.world.IsInAtmo()
            end,
            G = core.getGravityIntensity,
            AngularAirFrictionAcceleration = function()
                return Vec3(core.getWorldAirFrictionAcceleration())
            end
        },
        player = {
            position = {
                Current = function()
                    return Vec3(ctrl.getMasterPlayerWorldPosition())
                end
            },
            orientation = {
                Up = function()
                    return Vec3(ctrl.getMasterPlayerWorldUp())
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

    setmetatable(instance, vehicle)
    return instance
end

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