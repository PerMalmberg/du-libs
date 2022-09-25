---@module "Task"

---@class Taskmanager
---@field Instance fun():Taskmanager Returns the Taskmanager singleton
---@field Add fun(self:table, t:Task) Adds a task
---@field Count fun(self:table):number Returns the number of tasks


local Taskmanager = {}
Taskmanager.__index = {}
local instance

function Taskmanager.Instance()
    if instance then
        return instance
    end

    local s = {}
    local tasks = {} ---@type Task[]

    function s:Add(task)
        if type(task) ~= "table" or type(task.Run) ~= "function" then
            error("Can only add Tasks")
        end

        table.insert(tasks, task)
    end

    function s:Count()
        return #tasks
    end

    local function update()
        for i = 1, #tasks do
            local curr = tasks[i]
            if curr and curr:Run() == TaskState.Dead then
                table.remove(tasks, i)

                if not curr:Success() then
                    if curr.catcher then
                        curr.catcher(curr)
                    end
                end

                if curr.finalizer then
                    curr.finalizer(curr)
                end
            end
        end
    end

    instance = setmetatable(s, Taskmanager)

    unit:onEvent("onUpdate", update)

    return instance
end

return Taskmanager
