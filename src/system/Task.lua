local taskmanager = require("system/Taskmanager"):Instance()
local status = coroutine.status
local resume = coroutine.resume

---@enum TaskState
TaskState = {
    Dead = 0,
    Running = 1
}

---@class Task
---@field Run fun(self:Task):TaskState The status of the task
---@field Success fun(self:Task):boolean Returns true if the task succeeded
---@field Result fun(self:Task):any Returns the return value of the task, or the error if an error is raised.
---@field Exited fun(self:Task):boolean Returns true when the task has completed its work (or otherwise exited)
---@field Catch fun(self:Task, f:fun(t:Task)) Sets an error handler, called if the task raises an error
---@field Finally fun(self:Task, f:fun(t:Task)) Sets a finalizer, always called before the task is removed from the task manager.
---@field catcher fun(t:Task)
---@field finalizer fun(t:Task)

local Task = {}
Task.__index = Task

function Task.New(func)
    local s = {
        catcher = nil, ---@type function
        finalizer = nil, ---@type function
    }

    local f = coroutine.create(func)
    local resultValue ---@type any
    local success = true
    local exited = false

    function s:Run()
        if status(f) == "dead" then
            exited = true
            return TaskState.Dead
        else
            success, resultValue = resume(f)
            -- Coroutine potentially died here, but we handle that next round
            return TaskState.Running
        end
    end

    ---Sets an error handler
    ---@param catcher function
    function s:Catch(catcher)
        if type(catcher) ~= "function" then
            error("Can only add function as catchers")
        end

        s.catcher = catcher
        return s
    end

    ---Sets a finalizer
    ---@param finalizer function
    function s:Finally(finalizer)
        if type(finalizer) ~= "function" then
            error("Can only add function as catchers")
        end

        s.finalizer = finalizer
        return s
    end

    ---Indicates success of failure
    ---@return boolean
    function s:Success()
        return success
    end

    ---The result of the task
    ---@return any|nil
    function s:Result()
        return resultValue
    end

    ---Indicates if the task has completed its run
    ---@return boolean
    function s:Exited()
        return exited
    end

    setmetatable(s, Task)

    taskmanager:Add(s)

    return s
end

function Task.IsTask(task)
    return type(task) == "table" and type(task.Run) == "function"
end

---Waits for the task to complete
---@param task Task
---@return any
function Task.Await(task)
    if type(task) ~= "table" or type(task.Run) ~= "function" then
        error("Can only await a Task")
    end

    while not task:Exited() do
        coroutine.yield()
    end

    return task:Result()
end

return Task
