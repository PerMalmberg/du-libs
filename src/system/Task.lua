local taskmanager = require("system/Taskmanager"):Instance()
local status = coroutine.status
local resume = coroutine.resume

---@enum TaskState
TaskState = {
    Dead = 0,
    Running = 1
}

---@class Task
---@field New fun(f:fun():any):Task Creates a new Task and runs the function ansync.
---@field Run fun(self:Task):TaskState The status of the task
---@field Success fun(self:Task):boolean Returns true if the task succeeded
---@field Result fun(self:Task):any Returns the return value of the task, or the error if an error is raised.
---@field Exited fun(self:Task):boolean Returns true when the task has completed its work (or otherwise exited)
---@field Then fun(self:Task, f:fun(f:Task):any):Task Chains another call to be run when the previous one has completed.
---@field Catch fun(self:Task, f:fun(f:Task)):Task Sets an error handler, called if the task raises an error
---@field Finally fun(self:Task, f:fun(f:Task)):Task Sets a finalizer, always called before the task is removed from the task manager.
---@field catcher fun(t:Task)
---@field finalizer fun(t:Task)

local Task = {}
Task.__index = Task

---Create a new task
---@param toRun fun():any
---@return Task
function Task.New(toRun)
    local s = {
        catcher = nil, ---@type fun(f:Task):Task
        finalizer = nil, ---@type fun(f:Task):Task
    }

    local funcs = {} --- @type thread[]
    table.insert(funcs, coroutine.create(toRun))
    local resultValue ---@type any
    local success = true
    local exited = false

    function s:Run()
        local t = funcs[1]
        local dead = status(t) == "dead"

        if dead then
            -- Move to next, or are we done?
            if #funcs > 1 then
                table.remove(funcs, 1)
                t = funcs[1]
            else
                exited = true
                return TaskState.Dead
            end
        end

        success, resultValue = resume(t)
        -- Coroutine potentially died here, but we handle that next round
        return TaskState.Running
    end

    ---Chain another function to run after the previous one is completed
    ---@param thenfunc fun(self:Task, f:fun(thenFunc:Task))
    function s:Then(thenfunc)
        table.insert(funcs, coroutine.create(thenfunc))
        return s
    end

    ---Sets an error handler
    ---@param catcher fun(t:Task)
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
