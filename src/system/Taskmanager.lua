---@module "Task"

---@class Taskmanager
---@field Instance fun():Taskmanager Returns the Taskmanager singleton
---@field Add fun(t:Task) Adds a task
---@field Count fun():number Returns the number of tasks


local Taskmanager = {}
Taskmanager.__index = {}
local instance

function Taskmanager.Instance()
    if instance then
        return instance
    end

    local s = {}
    local tasks = {} ---@type Task[]

    ---@param task Task
    function s.Add(task)
        tasks[#tasks + 1] = task
    end

    function s.Count()
        return #tasks
    end

    local function update()
        local keep = {}
        for i, t in ipairs(tasks) do
            local curr = tasks[i]
            if curr.Run() == TaskState.Dead then
                if not curr.Success() then
                    if curr.catcher then
                        curr.catcher(curr)
                    end
                end

                if curr.finalizer then
                    curr.finalizer(curr)
                end
            else
                keep[#keep + 1] = curr
            end
        end

        tasks = keep
    end

    instance = setmetatable(s, Taskmanager)

    system:onEvent("onUpdate", update)

    return instance
end

return Taskmanager
