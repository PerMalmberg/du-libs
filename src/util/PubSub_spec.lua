local PubSub = require("util/PubSub")

describe("PubSub", function()
    it("Can publish to a topic", function()
        local a
        local b
        local aBoolean = false
        local bTable = {}

        PubSub.Instance().RegisterString("a", function(topic, value)
            a = value
        end)

        PubSub.Instance().RegisterString("b", function(topic, value)
            b = value
        end)

        assert.are_nil(a)
        assert.are_nil(b)

        PubSub.Instance().Publish("a", "value a")
        PubSub.Instance().Publish("b", "value b")

        assert.are_equal("value a", a)
        assert.are_equal("value b", b)

        PubSub.Instance().RegisterBool("a", function(topic, value)
            aBoolean = value
        end)
        PubSub.Instance().Publish("a", true)

        assert.is_true(aBoolean)

        PubSub.Instance().RegisterTable("b", function(topic, value)
            bTable = value
        end)

        assert.is_nil(bTable.a)

        PubSub.Instance().Publish("b", { a = "value in table" })

        assert.are_equal("value in table", bTable.a)

        local cdString
        PubSub.Instance().RegisterString("c", function(topic, value)
            cdString = value
        end)

        PubSub.Instance().RegisterString("d", function(topic, value)
            cdString = value
        end)

        assert.is_nil(cdString)

        PubSub.Instance().Publish("c", "c string")
        assert.are_equal("c string", cdString)

        PubSub.Instance().Publish("d", "d string")
        assert.are_equal("d string", cdString)

        local n = 0
        PubSub.Instance().RegisterNumber("n", function(topic, value)
            n = value
        end)

        PubSub.Instance().Publish("n", 123)
        assert.are_equal(123, n)

    end)

end)
