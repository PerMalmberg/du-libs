local PubSub = require("util/PubSub")

describe("PubSub", function()
    it("Can publish to a topic", function()
        local a
        local b

        PubSub.Instance().Register("a", function(topic, value)
            a = value
        end)

        PubSub.Instance().Register("b", function(topic, value)
            b = value
        end)

        assert.are_nil(a)
        assert.are_nil(b)

        PubSub.Instance().Publish("a", "value a")
        PubSub.Instance().Publish("b", "value b")

        assert.are_equal("value a", a)
        assert.are_equal("value b", b)

    end)

end)
