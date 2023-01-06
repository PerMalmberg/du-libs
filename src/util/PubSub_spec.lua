require("environment"):Prepare()
local PubSub = require("util/PubSub")
local Task = require("system/Task")

local function runUpdate(count)
    for i = 1, count do
        system:triggerEvent("onUpdate")
    end
end

local pub = PubSub.Instance()

describe("PubSub", function()
    it("Can publish to a topic", function()
        local a
        local b
        local aBoolean = false
        local bTable = {}

        pub.RegisterString("a", function(topic, value)
            a = value
        end)

        pub.RegisterString("b", function(topic, value)
            b = value
        end)

        assert.are_nil(a)
        assert.are_nil(b)

        pub.Publish("a", "value a")
        pub.Publish("b", "value b")

        assert.are_equal("value a", a)
        assert.are_equal("value b", b)

        pub.RegisterBool("a", function(topic, value)
            aBoolean = value
        end)
        pub.Publish("a", true)

        assert.is_true(aBoolean)

        pub.RegisterTable("b", function(topic, value)
            bTable = value
        end)

        assert.is_nil(bTable.a)

        pub.Publish("b", { a = "value in table" })

        assert.are_equal("value in table", bTable.a)

        local cdString
        pub.RegisterString("c", function(topic, value)
            cdString = value
        end)

        pub.RegisterString("d", function(topic, value)
            cdString = value
        end)

        assert.is_nil(cdString)

        pub.Publish("c", "c string")
        assert.are_equal("c string", cdString)

        pub.Publish("d", "d string")
        assert.are_equal("d string", cdString)

        local n = 0
        pub.RegisterNumber("n", function(topic, value)
            n = value
        end)

        pub.Publish("n", 123)
        assert.are_equal(123, n)
    end)

    it("Can publish in a Task", function()
        local a = {}

        pub.RegisterBool("yield", function(topic, value)
            table.insert(a, value)
        end)

        pub.RegisterString("yield", function(topic, value)
            table.insert(a, value)
        end)

        local t = Task.New("test", function()
            for i = 1, 10, 1 do
                pub.Publish("yield", true, true)
                pub.Publish("yield", "value", true)
            end
        end)

        runUpdate(30)
        assert.are_equal(20, #a)
    end)

    it("Can unsubscribe", function()
        local i = 0
        local callback = function(topic, value)
            i = value
        end
        pub.RegisterNumber("unsub", callback)

        pub.Publish("unsub", 1)
        assert.Equal(1, i)
        pub.Publish("unsub", 2)
        assert.Equal(2, i)
        pub.Unregister("unsub", callback)
        pub.Publish("unsub", 3)
        assert.Equal(2, i)
    end)
end)
