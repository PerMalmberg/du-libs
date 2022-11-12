local env = require("environment")
env.Prepare()

local calc = require("util/Calc")

describe("Calc", function()

    it("Can clamp", function()
        assert.are_equal(1, calc.Clamp(0, 1, 10))
        assert.are_equal(10, calc.Clamp(11, 1, 10))
        assert.are_equal(1, calc.Clamp(1, 1, 10))
        assert.are_equal(10, calc.Clamp(10, 1, 10))
    end)
end)
