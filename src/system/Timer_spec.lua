local env = require("environment")

describe("Timer", function()
    local Timer = require("system/Timer")

    it("test", function()
        env.Prepare()
        stub(unit, "setTimer")
        stub(unit, "stopTimer")

        local t = Timer.Instance()
        local id = "1234"
        local interval = 5678

        t.Add(id, function() end, interval)
        t.Remove(id)
        system:triggerEvent("onUpdate")

        assert.stub(unit.setTimer).was_called_with(id, interval)
        assert.stub(unit.stopTimer).was_called_with(id)
    end)

    it("Is a singelton", function()
        assert.are.equal(Timer.Instance(), Timer.Instance())
    end)

    it("Timer function called", function()
        local t = Timer.Instance()
        local count = 0

        t.Add("myEvent", function()
            count = count + 1
        end, 1)

        unit:triggerEvent("onTimer", "myEvent")
        assert.are_equal(1, count)
    end)
end)
