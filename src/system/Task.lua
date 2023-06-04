local taskmanager = require("system/Taskmanager").Instance()
local status = coroutine.status
local resume = coroutine.resume

---@enum TaskState
TaskState = {
    Dead = 0,
    Running = 1
}

---@alias thenFunc fun(...:any): any

---@class Task
---@field New fun(taskName:string, f:thenFunc, arg1:any?, ...:any[]?):Task Creates a new Task and runs the function ansync.
---@field Run fun():TaskState The status of the task
---@field Success fun():boolean Returns true if the task succeeded
---@field Result fun():any|nil Returns the return value of the task.
---@field Error fun():string|nil Returns the error message value of the task, if an error is raised.
---@field Exited fun():boolean Returns true when the task has completed its work (or otherwise exited)
---@field Then fun(f:thenFunc, thenArg1:any?, ...:any?):Task Chains another call to be run when the previous one has completed.
---@field Catch fun(f:fun(t:Task)):Task Sets an error handler, called if the task raises an error
---@field Finally fun(f:fun(t:Task)):Task Sets a finalizer, always called before the task is removed from the task manager.
---@field Name fun():string Returns the name of the Task
---@field catcher fun(t:Task)
---@field finalizer fun(t:Task)

local Task = {}
Task.__index = Task

---Create a new task
---@param taskName string The name of the task
---@param toRun fun():any
---@param arg1 any? First argument to function to be run
---@param ... any?[] Other arguments to be passed to the function to be run
---@return Task
function Task.New(taskName, toRun, arg1, ...)
    local s = {
        catcher = nil, ---@type fun(f:Task):Task
        finalizer = nil ---@type fun(f:Task):Task
    }

    local thenFunc = {} --- @type { co:thread, args:any[] }[]

    local function newThen(fun, ...)
        thenFunc[#thenFunc + 1] = { co = coroutine.create(fun), args = { ... } }
    end

    local resultValue ---@type any|nil
    local errorMessage ---@type string|nil
    local success = true
    local exited = false
    local name = taskName

    ---Moves to next call when needed
    local function next()
        if #thenFunc == 0 then
            return TaskState.Dead
        end

        local dead = status(thenFunc[1].co) == "dead"

        if dead then
            -- Move to next, or are we done?
            table.remove(thenFunc, 1)
            exited = #thenFunc == 0
            if exited then
                return TaskState.Dead
            end
        end

        return TaskState.Running
    end

    function s.Run()
        local result
        if next() == TaskState.Running then
            local t = thenFunc[1]
            success, result = resume(t.co, table.unpack(t.args))
        end

        if success then
            resultValue = result
            return next()
        end

        errorMessage = result
        return TaskState.Dead
    end

    ---Chain another function to run after the previous one is completed
    ---@param thenfunc fun(...:any[]?)
    ---@param thenArg1 any? First argument to function to be run
    ---@param ... any? Other arguments to be passed to the function to be run
    function s.Then(thenfunc, thenArg1, ...)
        newThen(thenfunc, thenArg1, ...)
        return s
    end

    ---Sets an error handler
    ---@param catcher fun(t:Task)
    function s.Catch(catcher)
        if type(catcher) ~= "function" then
            error("Can only add function as catchers")
        end

        s.catcher = catcher
        return s
    end

    ---Sets a finalizer
    ---@param finalizer fun(t:Task)
    function s.Finally(finalizer)
        if type(finalizer) ~= "function" then
            error("Can only add function as catchers")
        end

        s.finalizer = finalizer
        return s
    end

    ---Indicates success of failure
    ---@return boolean
    function s.Success()
        return success
    end

    ---The result of the task
    ---@return any|nil
    function s.Result()
        return resultValue
    end

    ---The error of the task
    ---@return string|nil
    function s.Error()
        return errorMessage
    end

    ---Indicates if the task has completed its run
    ---@return boolean
    function s.Exited()
        return exited
    end

    ---Gets the task name
    ---@return string
    function s.Name()
        return name
    end

    newThen(toRun, arg1, ...)
    setmetatable(s, Task)

    taskmanager.Add(s)

    return s
end

---Waits for the task to complete
---@param task Task
---@return any
function Task.Await(task)
    while not task.Exited() do
        coroutine.yield()
    end

    return task.Result()
end

return Task
