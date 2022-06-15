local log = require("debug/Log")()
local keys = require("input/Keys")

local input = {}
input.__index = input

local function new()
    local o = {
        lookup = {},
        leftControlHeld = false,
        leftAltHeld = false,
        leftShift = false,
        keyToModifier = {},
        keyState = {}
    }

    setmetatable(o, input)

    -- Create handles for each of the known input actions
    for _, m in ipairs(keys) do
        o.keyToModifier[m] = function(inp, status)
            inp.keyState[m] = status
        end

        -- Start with all keys in released state
        o.keyState[m] = false
    end

    system:onEvent("actionStart", o.keyPress, o)
    system:onEvent("actionStop", o.keyRelease, o)
    system:onEvent("actionLoop", o.keyHold, o)

    return o
end

function input:decode(key, status)
    local f = self.keyToModifier[key]
    if f == nil then
        log:Warning("Unsupported key: ", key)
    else
        f(self, status)
    end
end

function input:keyPress(key)
    self:decode(key, true)
end

function input:keyRelease(key)
    self:decode(key, false)
end

function input:keyHold(key)
    -- Holding a key means it is pressed
    self:keyPress(key)
end

-- Register a function to be triggered when a key is pressed and certain modifiers are set
function input:Register(key, modifiers, func)

end

local singleton

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                if singleton == nil then
                    singleton = new()
                end
                return singleton
            end
        }
)