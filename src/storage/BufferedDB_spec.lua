local env = require("environment")
local assert = require("luassert")
local stub = require("luassert.stub")
local json = require("dkjson")

local function runTicks()
    for i = 1, 1000, 1 do
        unit:triggerEvent("onTimer", "CoRunner0")
    end
end

describe("BufferedDB", function()
    env.Prepare()
    require("api-mockup/databank")

    local BufferedDB = require("storage/BufferedDB")
    local dataBank = Databank()

    stub(dataBank, "getKeyList")
    stub(dataBank, "getStringValue")
    dataBank.getKeyList.on_call_with().returns({ "a", "b", "table" })
    dataBank.getStringValue.on_call_with("a").returns(json.encode({ t = "string", v = "aValue" }))
    dataBank.getStringValue.on_call_with("b").returns(json.encode({ t = "number", v = 1 }))
    dataBank.getStringValue.on_call_with("table").returns(json.encode({ t = "table", v = { key = "value" } }))

    local db

    db = BufferedDB.New(dataBank)

    it("Has guard against writing before load", function()
        assert.is_false(db:IsDirty())
        assert.has_error(function()
            db:Put("myKey", "myValue")
        end, "Call to Put before loading is completed")
    end)

    it("Can load data", function()
        db:BeginLoad()
        while not db:IsLoaded() do
            runTicks()
        end
        assert.is_true(db:IsLoaded())
        assert.are_equal("aValue", db:Get("a"))
        assert.are_equal(1, db:Get("b"))
        assert.are_equal("value", db:Get("table").key)
    end)

    it("Doesn't allow to save functions", function()
        assert.has_error(function()
            db:Put("abc", { key = function() end })
        end, "Cannot store tables with functions")
    end)

    it("Can store numbers", function()
        assert.is_false(db:IsDirty())
        db:Put("myNumber", 123)
        assert.is_true(db:IsDirty())
        runTicks()
        assert.is_false(db:IsDirty())

        assert.are_equal(123, db:Get("myNumber", 0))
    end)

    it("Can store strings", function()
        assert.is_false(db:IsDirty())
        db:Put("myKey", "myValue")
        assert.is_true(db:IsDirty())
        runTicks()
        assert.is_false(db:IsDirty())
    end)

    it("Can store tables", function()
        assert.is_false(db:IsDirty())
        db:Put("myKey", { key = "value" })
        assert.is_true(db:IsDirty())
        runTicks()
        assert.is_false(db:IsDirty())
    end)


end)
