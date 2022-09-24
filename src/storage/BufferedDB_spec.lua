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
    local keys = { "a", "b", "table", "invalid_data" }
    for i = 1, 10, 1 do
        local key = "key" .. i
        table.insert(keys, key)
        dataBank.getStringValue.on_call_with(key).returns(json.encode({ t = "string", v = "aValue" .. i }))
    end

    dataBank.getKeyList.on_call_with().returns(keys)
    dataBank.getStringValue.on_call_with("a").returns(json.encode({ t = "string", v = "aValue" }))
    dataBank.getStringValue.on_call_with("b").returns(json.encode({ t = "number", v = 1 }))
    dataBank.getStringValue.on_call_with("table").returns(json.encode({ t = "table", v = { key = "value" } }))
    dataBank.getStringValue.on_call_with("invalid_data").returns(json.encode({ invalid_data = "for this class" }))

    local db

    db = BufferedDB.New(dataBank)

    it("Has guards against reading/writing before load", function()
        assert.is_false(db:IsDirty())
        assert.has_error(function()
            db:Put("myKey", "myValue")
        end, "Call to Put before loading is completed")

        assert.has_error(function()
            db:Get("myKey")
        end, "Call to Get before loading is completed")

        assert.has_error(function()
            db:Clear()
        end, "Call to Clear before loading is completed")

        assert.has_error(function()
            db = BufferedDB.New({})
        end, "databank parameter of BufferedDB.New must be a link to a databank")

        assert.has_error(function()
            db = BufferedDB.New(nil)
        end, "databank parameter of BufferedDB.New must be a link to a databank")
    end)

    it("Can load data", function()
        db:BeginLoad()
        while not db:IsLoaded() do
            runTicks()
        end
        assert.is_true(db:IsLoaded())
        assert.are_equal(13, db:Size())
        assert.are_equal("aValue", db:Get("a"))
        assert.are_equal(1, db:Get("b"))
        assert.are_equal("value", db:Get("table").key)
    end)

    it("Doesn't allow to save functions", function()
        assert.has_error(function()
            db:Put("abc", { key = function() end })
        end, "Cannot store tables with functions")

        assert.has_error(function()
            db:Put("abc", { key = { subKey = function() end } })
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
        db:Put("myString", "myValue")
        assert.is_true(db:IsDirty())
        runTicks()
        assert.is_false(db:IsDirty())
    end)

    it("Can store tables", function()
        assert.is_false(db:IsDirty())
        db:Put("myTable", { key = "table value" })
        assert.is_true(db:IsDirty())
        runTicks()
        assert.is_false(db:IsDirty())
        assert.are_equal("table value", db:Get("myTable").key)
    end)

    it("Can clear keys", function()
        assert.are_equal(16, db:Size())
        db:Clear()
        assert.are_equal(0, db:Size())
    end)

    it("Can return default value", function()
        assert.are_equal(123, db:Get("blah", 123))
    end)
end)
