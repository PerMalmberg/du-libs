local DB = require("storage/BufferedDB")
local log = require("debug/Log")()
local typeComp = require("debug/TypeComp")
local Task = require("system/Task")
local Stopwatch = require("system/Stopwatch")

log:SetLevel(log.LogLevel.DEBUG)

local test = {}

function test.InitDB()
    local t = Task.New(function()
        local db = DB("TestDB")
        db:Clear()
        assert(db:BeginLoad(), "Failed to initialize DB")

        while not db:IsLoaded() do
            coroutine.yield()
        end

        db:Put("a", { foo = "bar" })
        local a = db:Get("a")
        assert(typeComp.IsTable(a))
        assert(a.foo == "bar")

        db:Put("b", 1)
        local b = db:Get("b")
        assert(typeComp.IsNumber(b))
        assert(b == 1, "b is not 1")

        db:Put("c", "abcdef")
        local c = db:Get("c")
        assert(typeComp.IsString(c))
        assert(c == "abcdef", "c is not abcdef")

        local c = db:Get("c", "1234")
        assert(c == "abcdef")


        while db:IsDirty() do
            coroutine.yield()
        end

        db:Clear()
        a = db:Get("a", { foo = "boo" })
        assert(a.foo == "boo")

        log:Info("Test complete")
        unit.exit()
    end)

    Task.Await(Task.New(function()
        local sw = Stopwatch.New()
        while sw:Elapsed() < 10 do
            coroutine.yield()
        end
        log:Error("Test failed")
        unit.exit()
    end))
end
