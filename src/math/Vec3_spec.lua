local Vec3 = require("math/Vec3")

describe("Vec3", function()
    it("Can create a new Vec3", function()
        local v = Vec3.New(1, 2, 3)
        assert.are_equal(1, v.x)
        assert.are_equal(2, v.y)
        assert.are_equal(3, v.z)
    end)

    it("Can create zero vec", function()
        assert.are_equal(Vec3.New(0), Vec3.New())
        assert.are_equal(Vec3.New(0, 0, 0), Vec3.New())
    end)

    it("Can create from table", function()
        assert.are_equal(Vec3.New(1, 2, 3), Vec3.New({ 1, 2, 3 }))
    end)

    it("Can multiply", function()
        local res = Vec3.New(1, 2, 3) * 3
        assert.are_equal(Vec3.New(3, 6, 9), res)
        assert.is_true(Vec3.New(3, 6, 9) == res)
        res = 3 * Vec3.New(1, 2, 3)
        assert.are_equal(Vec3.New(3, 6, 9), res)
    end)

    it("Can divide", function()
        local res = Vec3.New(3, 6, 9) / 3
        assert.are_equal(Vec3.New(1, 2, 3), res)
    end)

    it("Can do the dot product", function()
        local dot = Vec3.New(1, 2, 3):Dot(Vec3.New(1, 5, 7))
        assert.are_equal(32, dot)
    end)

    it("Can do the cross product", function()
        local cross = Vec3.New(1, 2, 3):Cross(Vec3.New(1, 5, 7))
        assert.are_equal(Vec3.New(-1, -4, 3), cross)
    end)

    it("Can normalize a vector", function()
        local v = Vec3.New(2, -4, 1)
        local len = v:Len2()
        local norm = v:Normalize()

        assert.are_equal(1, norm:Len())
        assert.are_equal(2 / math.sqrt(len), norm.x)
        assert.are_equal(-4 / math.sqrt(len), norm.y)
        assert.are_equal(1 / math.sqrt(len), norm.z)

        assert.are_equal(2, v.x)
        assert.are_equal(-4, v.y)
        assert.are_equal(1, v.z)
    end)
end)
