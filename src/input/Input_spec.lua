require("environment"):Prepare()
local Input = require("input/Input")
local keys = require("input/Keys")
local Criteria = require("input/Criteria")
local input = Input.Instance()

local function Press(key)
    system:triggerEvent("onActionStart", keys.Name(key))
end

local function Release(key)
    system:triggerEvent("onActionStop", keys.Name(key))
end

local function Repeat(key)
    system:triggerEvent("onActionLoop", keys.Name(key))
end

describe("Input", function()
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
end)
