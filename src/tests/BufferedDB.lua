local DB = require("storage/BufferedDB")
local log = require("debug/Log")()
local co = require("system/CoRunner")(0.1)

log:SetLevel(log.LogLevel.DEBUG)

local test = {}

function test.InitDB()
    local db = DB("TestDB")
    assert(db:BeginLoad(), "Failed to initialize DB")
    co:Execute(function()
        while not db:IsLoaded() do
            coroutine.yield()
        end

        db:Put("a", { foo = "bar" })

        while db:IsDirty() do
            coroutine.yield()
        end

        --local read = db:ReadObject("a")
        --assert(read.foo == "bar")

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