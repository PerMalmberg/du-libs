local massFormat = require("util/MassFormat")

describe("Mass format", function()
    it("Can format kilos", function()
        local res = massFormat(999.99)
        assert.equal(999.99, res.value)
        assert.equal("kg", res.unit)
    end)

    it("Can format tons", function()
        local res = massFormat(1000)
        assert.equal(1, res.value)
        assert.equal("t", res.unit)

        local res = massFormat(1001)
        assert.equal(1.001, res.value)
        assert.equal("t", res.unit)

        res = massFormat(5101)
        assert.equal(5.101, res.value)
        assert.equal("t", res.unit)
    end)


    it("Can format kilotons", function()
        local res = massFormat(1000 * 1000)
        assert.equal(1, res.value)
        assert.equal("kt", res.unit)

        local res = massFormat(1001 * 1000)
        assert.equal(1.001, res.value)
        assert.equal("kt", res.unit)

        res = massFormat(5101 * 1000)
        assert.equal(5.101, res.value)
        assert.equal("kt", res.unit)

    end)
end)
