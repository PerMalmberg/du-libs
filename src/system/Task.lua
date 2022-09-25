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
---@field Result fun(self:Task):any Returns the return value of the task
---@field Exited fun(self:Task):boolean Returns true when the task has completed its work (or otherwise exited)


local Task = {}
Task.__index = Task

function Task.New(func)
    local s = {}

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




--[[ function Task(func)
    local self = {}
    self.LastReturn = nil
    self.Error = nil
    self.Finished = false
    if type(func) ~= "function" then error("[Task] Not a function.") end
    self.Coroutine = coroutine.create(func)

    function self.Then(func)
        if type(func) ~= "function" then error("[Task] Then callback not a function.") end
        self._Then = func
        return self
    end

    function self.Finally(func)
        if type(func) ~= "function" then error("[Task] Finally callback not a function.") end
        self._Finally = func
        return self
    end

    function self.Catch(func)
        if type(func) ~= "function" then error("[Task] Catch callback not a function.") end
        self._Catch = func
        return self
    end

    TaskManager.Register(self)
    return self
end ]]
