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

    it("Can copy a table", function()
        local a = { 1, 2, 3, foo = { 4, 5 } }
        local b = DeepCopy(a)
        assert.Equal(a[1], b[1])
        assert.Equal(a[2], b[2])
        assert.Equal(a[3], b[3])
        assert.Equal(a["foo"][1], b["foo"][1])
        assert.Equal(a["foo"][2], b["foo"][2])
    end)
end)
