--[[
    Library abstraction. This is assumes the project is being compiled with du-LuaC (https://github.com/wolfe-labs/DU-LuaC/) which provides
    a GetCoreUnit() function via the global 'library'.
]]

local libraryProxy = {}
libraryProxy.__index = libraryProxy

local singleton

local function new()
    return setmetatable({}, libraryProxy)
end

function libraryProxy:GetCoreUnit()
    -- Are we running live?
    if library then
        return library.getCoreUnit()
    else
        -- In test, return a mock
        return require("mock/Core")()
    end
end

function libraryProxy:GetController()
    if library then
        return unit -- Return the global unit
    else
        return require("mock/Controller")()
    end
end

function libraryProxy:GetSolver3()
    if library then
        return library.systemResolution3
    end
    return nil
end

function libraryProxy:GetLinks(filter, noLinkName)
    if library then
        return library.getLinks(filter, noLinkName)
    end
    return nil
end

function libraryProxy:GetLinkByName(name, noLinkName)
    if library then
        return library.getLinkByName(name, noLinkName)
    end
    return nil
end

function libraryProxy:GetLinkByClass(class, noLinkName)
    if library then
        return library.getLinkByClass(class, noLinkName)
    end
    return nil
end

function libraryProxy:AddEventHandlers(obj)
    if library then
        library.addEventHandlers(obj)
    end
end

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