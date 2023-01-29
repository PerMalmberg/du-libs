---@class ContainerTalents
---@field New fun(containerProficiency:integer, fuelTankOptimization:integer,containerOptimization:integer,atmoFuelTankHandling:integer,spaceFuelTankHandling:integer,rocketFuelTankHandling:integer):ContainerSkills
---@field ContainerProficiency integer
---@field FuelTankOptimization integer
---@field ContainerOptimization integer
---@field AtmoFuelTankHandling integer
---@field SpaceFuelTankHandling integer
---@field RocketFuelTankHandling integer

local ContainerSkills = {}
ContainerSkills.__index = ContainerSkills

---@param containerProficiency integer,
---@param fuelTankOptimization integer,
---@param containerOptimization integer,
---@param atmoFuelTankHandling integer,
---@param spaceFuelTankHandling integer,
---@param rocketFuelTankHandling integer
---@return ContainerTalents
function ContainerSkills.New(containerProficiency, fuelTankOptimization, containerOptimization, atmoFuelTankHandling,
                             spaceFuelTankHandling, rocketFuelTankHandling)
    local s = {
        ContainerProficiency = containerProficiency or 0,
        FuelTankOptimization = fuelTankOptimization or 0,
        ContainerOptimization = containerOptimization or 0,
        AtmoFuelTankHandling = atmoFuelTankHandling or 0,
        SpaceFuelTankHandling = spaceFuelTankHandling or 0,
        RocketFuelTankHandling = rocketFuelTankHandling or 0
    }

    return setmetatable(s, ContainerSkills)
end

return ContainerSkills
