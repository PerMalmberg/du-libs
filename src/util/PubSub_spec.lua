local PubSub = require("util/PubSub")

describe("PubSub", function()
    it("Can publish to a topic", function()
        local p = PubSub.Instance()

        local a
        local b

        p.Register("a", function(topic, value)
            a = value
        end)

        p.Register("b", function(topic, value)
            b = value
        end)

        assert.are_nil(a)
        assert.are_nil(b)

        p.Publish("a", "value a")
        p.Publish("b", "value b")

        assert.are_equal("value a", a)
        assert.are_equal("value b", b)

    end)

end)
