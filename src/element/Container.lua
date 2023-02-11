local ContainerTalents = require("element/ContainerTalents")
local Task = require("system/Task")
local log = require("debug/Log")()

---@class Container
---@field New fun(itemId:integer):Container
---@field Name fun():string
---@field GetAll fun():Container[]
---@field FuelFillFactor fun(talents:ContainerTalents)
---@field ActualContentMass fun(talents:ContainerTalents)

local core = library.getCoreUnit()
local nitronMass = 4
local kergonMass = 6
local xeronMass = 0.8

if core == nil then
    error("No core linked")
end

---@alias ContainerData {Cap:number, Factor:number, FuelMass:number}
local sizes = {} ---@type table<string,ContainerData>
sizes["basic container xs"] = { Cap = 1000, Factor = 1 }
sizes["uncommon optimised container xs"] = { Cap = 1300, Factor = 1 }
sizes["advanced optimised container xs"] = { Cap = 1690, Factor = 1 }
sizes["rare optimised container xs"] = { Cap = 2197, Factor = 1 }
sizes["exotic optimised container xs"] = { Cap = 2856, Factor = 1 }
sizes["uncommon gravity-inverted container xs"] = { Cap = 900, Factor = 0.9 }
sizes["advanced gravity-inverted container xs"] = { Cap = 810, Factor = 0.81 }
sizes["rare gravity-inverted container xs"] = { Cap = 729, Factor = 0.73 }
sizes["exotic gravity-inverted container xs"] = { Cap = 656, Factor = 0.66 }

sizes["basic container s"] = { Cap = 8000, Factor = 1 }
sizes["uncommon optimised container s"] = { Cap = 10400, Factor = 1 }
sizes["advanced optimised container s"] = { Cap = 13520, Factor = 1 }
sizes["rare optimised container s"] = { Cap = 17576, Factor = 1 }
sizes["exotic optimised container s"] = { Cap = 22849, Factor = 1 }
sizes["uncommon gravity-inverted container s"] = { Cap = 7200, Factor = 0.9 }
sizes["advanced gravity-inverted container s"] = { Cap = 6480, Factor = 0.81 }
sizes["rare gravity-inverted container s"] = { Cap = 5832, Factor = 0.73 }
sizes["exotic gravity-inverted container s"] = { Cap = 5249, Factor = 0.66 }

sizes["basic container m"] = { Cap = 64000, Factor = 1 }
sizes["uncommon optimised container m"] = { Cap = 83200, Factor = 1 }
sizes["advanced optimised container m"] = { Cap = 108160, Factor = 1 }
sizes["rare optimised container m"] = { Cap = 140608, Factor = 1 }
sizes["exotic optimised container m"] = { Cap = 182790, Factor = 1 }
sizes["uncommon gravity-inverted container m"] = { Cap = 57600, Factor = 0.9 }
sizes["advanced gravity-inverted container m"] = { Cap = 51840, Factor = 0.81 }
sizes["rare gravity-inverted container m"] = { Cap = 46656, Factor = 0.73 }
sizes["exotic gravity-inverted container m"] = { Cap = 41990, Factor = 0.66 }

sizes["basic container l"] = { Cap = 128000, Factor = 1 }
sizes["uncommon optimised container l"] = { Cap = 166400, Factor = 1 }
sizes["advanced optimised container l"] = { Cap = 216320, Factor = 1 }
sizes["rare optimised container l"] = { Cap = 281216, Factor = 1 }
sizes["exotic optimised container l"] = { Cap = 365581, Factor = 1 }
sizes["uncommon gravity-inverted container l"] = { Cap = 115200, Factor = 0.9 }
sizes["advanced gravity-inverted container l"] = { Cap = 103680, Factor = 0.81 }
sizes["rare gravity-inverted container l"] = { Cap = 93312, Factor = 0.73 }
sizes["exotic gravity-inverted container l"] = { Cap = 83981, Factor = 0.66 }

sizes["basic container xl"] = { Cap = 256000, Factor = 1 }
sizes["uncommon optimised container xl"] = { Cap = 332800, Factor = 1 }
sizes["advanced optimised atmoFuelTankHandlingcontainer xl"] = { Cap = 432640, Factor = 1 }
sizes["rare optimised container xl"] = { Cap = 562432, Factor = 1 }
sizes["exotic optimised container xl"] = { Cap = 731162, Factor = 1 }
sizes["uncommon gravity-inverted container xl"] = { Cap = 230400, Factor = 0.9 }
sizes["advanced gravity-inverted container xl"] = { Cap = 207360, Factor = 0.81 }
sizes["rare gravity-inverted container xl"] = { Cap = 186624, Factor = 0.73 }
sizes["exotic gravity-inverted container xl"] = { Cap = 167962, Factor = 0.66 }

sizes["expanded basic container xxl"] = { Cap = 512000, Factor = 1 }
sizes["expanded uncommon optimised container xxl"] = { Cap = 665600, Factor = 1 }
sizes["expanded advanced optimised container xxl"] = { Cap = 865280, Factor = 1 }
sizes["expanded rare optimised container xxl"] = { Cap = 1124864, Factor = 1 }
sizes["expanded exotic optimised container xxl"] = { Cap = 1462323, Factor = 1 }
sizes["expanded uncommon gravity-inverted container xxl"] = { Cap = 460800, Factor = 0.9 }
sizes["expanded advanced gravity-inverted container xxl"] = { Cap = 414720, Factor = 0.81 }
sizes["expanded rare gravity-inverted container xxl"] = { Cap = 373248, Factor = 0.73 }
sizes["expanded exotic gravity-inverted container xxl"] = { Cap = 335923, Factor = 0.66 }

sizes["atmospheric fuel tank xs"] = { Cap = 100, Factor = 1, FuelMass = nitronMass }
sizes["atmospheric fuel tank s"] = { Cap = 400, Factor = 1, FuelMass = nitronMass }
sizes["atmospheric fuel tank m"] = { Cap = 1600, Factor = 1, FuelMass = nitronMass }
sizes["atmospheric fuel tank l"] = { Cap = 12800, Factor = 1, FuelMass = nitronMass }

sizes["space fuel tank xs"] = { Cap = 100, Factor = 1, FuelMass = kergonMass }
sizes["space fuel tank s"] = { Cap = 400, Factor = 1, FuelMass = kergonMass }
sizes["space fuel tank m"] = { Cap = 1600, Factor = 1, FuelMass = kergonMass }
sizes["space fuel tank l"] = { Cap = 12800, Factor = 1, FuelMass = kergonMass }

sizes["rocket fuel tank xs"] = { Cap = 400, Factor = 1, FuelMass = xeronMass }
sizes["rocket fuel tank s"] = { Cap = 800, Factor = 1, FuelMass = xeronMass }
sizes["rocket fuel tank m"] = { Cap = 6400, Factor = 1, FuelMass = xeronMass }
sizes["rocket fuel tank l"] = { Cap = 50000, Factor = 1, FuelMass = xeronMass }

---Looksup the container data, or errors if not found
---@param name string
---@return ContainerData
local function lookupContainerData(name)
    local d = sizes[name]
    if not d then
        error(string.format("Unknown container: %s", name))
    end

    return d
end

---@enum ContainerType
ContainerType = {
    Standard = 1,
    Atmospheric = 2,
    Space = 4,
    Rocket = 8,
    Fuel = 14,
    All = 15
}

local Container = {}
Container.__index = Container
local preFiltered ---@type table<ContainerType, Container[]>


---Creates a new container
---@param localId integer The local id of the container
---@param containerData ContainerData
---@return Container
function Container.New(localId, unitMass, containerData)
    local function rawMass()
        return core.getElementMassById(localId)
    end

    local s = {
        ---@type string
        name = core.getElementNameById(localId)
    }

    local function standardVolume(containerProficiency)
        return containerData.Cap * (1 + containerProficiency / 10) -- 10% per level
    end

    local function fuelVolume(containerProficiency)
        return containerData.Cap * (1 + containerProficiency / 5) -- 20% per level
    end

    local function rawContentMass()
        return core.getElementMassById(localId) - unitMass;
    end

    ---Returns to which factor (0...1) the container is filled, if it is a fuel tank; otherwise 0.
    ---@param talents ContainerTalents
    function s.FuelFillFactor(talents)
        if not containerData.FuelMass then return 0 end

        local reducedMass = rawContentMass()
        local actualMass = reducedMass

        if talents.FuelTankOptimization > 0 or talents.ContainerOptimization > 0 then
            actualMass = reducedMass / (1 - (talents.FuelTankOptimization + talents.ContainerOptimization) * 0.05)
        end

        local volume
        if containerData.FuelMass == xeronMass then
            volume = fuelVolume(talents.RocketFuelTankHandling)
        elseif containerData.FuelMass == kergonMass then
            volume = fuelVolume(talents.SpaceFuelTankHandling)
        else
            volume = fuelVolume(talents.AtmoFuelTankHandling)
        end

        local currentLiters = actualMass / containerData.FuelMass
        local fillFactor = currentLiters / volume

        return fillFactor
    end

    ---@param talents ContainerTalents
    function s.ActualContentMass(talents)
        local reducedMass = rawContentMass()
        local actualMass = reducedMass
        if talents.ContainerOptimization > 0 then
            actualMass = reducedMass / (1 - talents.ContainerOptimization * 0.05)
        end

        return actualMass
    end

    ---Gets the container name
    ---@return string
    function s.Name()
        return s.name
    end

    return setmetatable(s, Container)
end

---@param localId number
---@return Container
local function makeContainer(localId)
    local itemId = core.getElementItemIdById(localId)
    ---@type {name:string, unitMass:number, unitVolume:number, displayNameWithSize:string}
    local data = system.getItem(itemId)
    local lowerName = data.displayNameWithSize:lower()
    local containerData = lookupContainerData(lowerName)
    return Container.New(localId, data.unitMass, containerData)
end

---@param input ContainerType
---@param wanted ContainerType
local function hasBit(input, wanted)
    return (input & wanted) == wanted
end

---Gets all containers. Only call from a coroutine
---@param filter ContainerType|integer
---@return Container[]
function Container.GetAllCo(filter)
    local containers = {} ---@type Container[]

    if not preFiltered then
        preFiltered = {}
        preFiltered[ContainerType.Standard] = {}
        preFiltered[ContainerType.Atmospheric] = {}
        preFiltered[ContainerType.Space] = {}
        preFiltered[ContainerType.Rocket] = {}

        ---@diagnostic disable-next-line: undefined-field
        for _, localId in ipairs(core.getElementIdList()) do
            local elementClass = core.getElementClassById(localId) ---@type string
            elementClass = elementClass:lower()

            if not elementClass:find("itemcontainer") then -- filter hubs
                if elementClass:find("atmofuelcontainer") then
                    table.insert(preFiltered[ContainerType.Atmospheric], makeContainer(localId))
                elseif elementClass:find("spacefuelcontainer") then
                    table.insert(preFiltered[ContainerType.Space], makeContainer(localId))
                elseif elementClass:find("rocketfuelcontainer") then
                    table.insert(preFiltered[ContainerType.Rocket], makeContainer(localId))
                elseif elementClass:find("container") and elementClass:find("fuel") then
                    table.insert(preFiltered[ContainerType.Standard], makeContainer(localId))
                end
            end
            coroutine.yield()
        end
    end

    if (hasBit(filter, ContainerType.Atmospheric)) then
        CopyTable(containers, preFiltered[ContainerType.Atmospheric])
    end

    if (hasBit(filter, ContainerType.Space)) then
        CopyTable(containers, preFiltered[ContainerType.Space])
    end

    if (hasBit(filter, ContainerType.Rocket)) then
        CopyTable(containers, preFiltered[ContainerType.Rocket])
    end

    if (hasBit(filter, ContainerType.Standard)) then
        CopyTable(containers, preFiltered[ContainerType.Standard])
    end

    return containers
end

return Container
