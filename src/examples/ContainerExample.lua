local Container = require("element/Container")
local Task = require("system/Task")
local ContainerTalents = require("element/ContainerTalents")

local t = Task.New("GetContainers", function()
    local all = Container.GetAllCo(ContainerType.Fuel)
    for _, t in ipairs(all) do
        system.print(t.FuelFillFactor(ContainerTalents.New(5, 5, 5, 5, 5, 0)))
    end
end).Catch(function(t)
    system.print(t.Error())
end)
