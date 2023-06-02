require("compat/Compat")

it("Can handle an integer", function()
    assert.True(I2B(true))
    assert.False(I2B(false))
end)

it("Can handle a boolean", function()
    assert.True(I2B(1))
    assert.False(I2B(0))
end)
