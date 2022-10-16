require("util/Table")

describe("Table", function()
    it("Can reverse an even list", function()
        local a = { 1, 2, 3, 4 }
        ReverseInplace(a)
        assert.are_equal(4, a[1])
        assert.are_equal(3, a[2])
        assert.are_equal(2, a[3])
        assert.are_equal(1, a[4])
    end)

    it("Can reverse an odd list", function()
        local a = { 1, 2, 3 }
        ReverseInplace(a)
        assert.are_equal(3, a[1])
        assert.are_equal(2, a[2])
        assert.are_equal(1, a[3])
    end)
end)
