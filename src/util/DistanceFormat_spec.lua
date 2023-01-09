local distFormat = require("util/DistanceFormat")

describe("Distance format", function()
    it("Can format meters", function()
        local res = distFormat(999.99)
        assert.equal(999.99, res.value)
        assert.equal("m", res.unit)
    end)


    it("Can format kilometers", function()
        local res = distFormat(1000)
        assert.equal(1, res.value)
        assert.equal("km", res.unit)

        res = distFormat(1001)
        assert.equal(1.001, res.value)
        assert.equal("km", res.unit)

        res = distFormat(5101)
        assert.equal(5.101, res.value)
        assert.equal("km", res.unit)
    end)


    it("Can format su", function()
        local oneSU = 200000

        local res = distFormat(oneSU)
        assert.equal(1, res.value)
        assert.equal("su", res.unit)

        res = distFormat(2 * oneSU)
        assert.equal(2, res.value)
        assert.equal("su", res.unit)

        res = distFormat(2.5 * oneSU)
        assert.equal(2.5, res.value)
        assert.equal("su", res.unit)
    end)
end)
