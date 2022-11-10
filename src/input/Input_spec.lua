require("environment"):Prepare()
local Input = require("input/Input")
local keys = require("input/Keys")
local Criteria = require("input/Criteria")
local input = Input.Instance()

---@param key integer
local function Press(key)
    system:triggerEvent("onActionStart", keys.Name(key))
end

---@param key integer
local function Release(key)
    system:triggerEvent("onActionStop", keys.Name(key))
end

---@param key integer
local function Repeat(key)
    system:triggerEvent("onActionLoop", keys.Name(key))
end

describe("Input", function()
    it("Is a singelton", function()
        assert.are_equal(input, Input.Instance())
    end)

    it("Can react to key press and release", function()
        local press = 0
        local release = 0
        input.Register(keys.lshift, Criteria.New().OnPress(), function()
            press = press + 1
        end)
        input.Register(keys.lshift, Criteria.New().OnRelease(), function()
            release = release + 1
        end)

        Press(keys.lshift)
        assert.are_equal(1, press)
        assert.are_equal(0, release)
        Release(keys.lshift)
        assert.are_equal(1, press)
        assert.are_equal(1, release)
    end)

    it("Can handle key repeat", function()
        local repeatCount = 0
        input.Register(keys.forward, Criteria.New().OnRepeat(), function()
            repeatCount = repeatCount + 1
        end)

        Repeat(keys.forward)
        Repeat(keys.forward)
        assert.are_equal(2, repeatCount)
        Repeat(keys.booster)
        assert.are_equal(2, repeatCount)
    end)

    it("Can handle multiple actions on the same key, with different criteria", function()
        local count = 0
        input.Register(keys.left, Criteria.New().OnPress(), function()
            count = count + 1
        end)

        input.Register(keys.left, Criteria.New().OnRelease(), function()
            count = count + 1
        end)

        Press(keys.left)
        Release(keys.left)
        assert.are_equal(2, count)
    end)

    it("Can clear handlers", function()
        local count = 0
        input.Clear()
        input.Register(keys.left, Criteria.New().OnPress(), function()
            count = count + 1
        end)

        Press(keys.left)
        assert.are_equal(1, count)
        input.Clear()
        Press(keys.left)
        assert.are_equal(1, count)

    end)
end)
