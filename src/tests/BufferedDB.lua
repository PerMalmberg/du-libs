local DB = require("storage/BufferedDB")
local log = require("debug/Log")()
local typeComp = require("debug/TypeComp")
local co = require("system/CoRunner")(0.1)

log:SetLevel(log.LogLevel.DEBUG)

local test = {}

function test.InitDB()
    co:Execute(function()
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
        a = db:Get("a", {foo = "boo"})
        assert(a.foo == "boo")

        log:Info("Test complete")
        unit.exit()
    end)

    co:Delay(function()
        log:Error("Test failed")
        unit.exit()
    end, 10)
end

local status, err, _ = xpcall(function()
    test.InitDB()
end, traceback)

if not status then
    system.print(err)
end