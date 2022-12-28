local Container = require("element/Container")
local Task = require("system/Task")

local t = Task.New("GetContainers", function()
    local all = Container.GetAllCo(ContainerType.Standard)
end).Catch(function(t)
    system.print(t.Error())
end)
