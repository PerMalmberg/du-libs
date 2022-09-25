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
            end
        end
    end

    instance = setmetatable(s, Taskmanager)

    unit:onEvent("onUpdate", update)

    return instance
end

return Taskmanager

--[[ TaskManager = (function()
    function self.Update()
        for i = 1, #self.Stack do
            local task = self.Stack[i]
            if task and task.Coroutine ~= nil then
                if coroutine.status(task.Coroutine) ~= "dead" then
                    local state, retn = coroutine.resume(task.Coroutine)
                    task.Error = not state
                    task.LastReturn = retn
                else
                    table.remove(self.Stack, i)
                    if task.Error and task._Catch then
                        task._Catch(task.LastReturn)
                    elseif task._Then ~= nil then
                        task._Then(task.LastReturn)
                    end
                    if task._Finally ~= nil then task._Finally() end
                    task.Finished = true
                end
            end
        end
    end

    return self
end)() ]]




--[[ Place the script above in system.start, and add the following to system.update:

  Quote
TaskManager.Update()

You are then able to create tasks, by wrapping a normal function. After the task finishes executing, the Then is called, and after that - Finally. Then is only called if the task completed without an error - Otherwise Catch is called(if present). An example:

local test = Task(function()
    coroutine.yield()
    coroutine.yield()
    coroutine.yield()
    sum = 0
    for i=1,50 do
        sum = sum + i
        coroutine.yield()
    end
    return sum
end)

test.Then(function(val) print("Returned: ".. val) end)
.Catch(function(err) print("Error: "..err) end)
.Finally(function() print("End of tests") end)


	Output:

	Cycle: 1
	[redacted for briefness]
	Cycle: 55
	Returned: 1275
	End of tests

You can also use the await function to halt task execution until the task passed into await is finished.

local asyncTest = Task(function()
    coroutine.yield()
    coroutine.yield()
    coroutine.yield()
    return "finished asyncTest"
end)

Task(function()
    local retn = await(asyncTest)
    print("await test: "..retn)
end)


	Output:

	await test: finished asyncTest



]]
