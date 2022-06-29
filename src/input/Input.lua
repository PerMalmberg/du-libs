local keys = require("input/Keys")

local input = {}
input.__index = input

local function new()
    local o = {
        lookup = {},
        keyState = {}
    }

    setmetatable(o, input)

    -- Create handles for each of the known input actions
    for _, k in ipairs(keys) do
        -- Start with all keys in released state
        o.keyState[k] = false
    end

    system:onEvent("onActionStart", o.keyPress, o)
    system:onEvent("onActionStop", o.keyRelease, o)
    system:onEvent("onActionLoop", o.keyHold, o)

    return o
end

function input:decode(key, isPressed, isRepeat)
    self.keyState[key] = isPressed

    local l = self.lookup[key]
    if l ~= nil then
        for _, entry in ipairs(l) do
            if entry.criteria:Matches(self, isRepeat, isPressed) then
                entry.func()
            end
        end
    end
end

function input:keyPress(key)
    self:decode(key, true, false)
end

function input:keyRelease(key)
    self:decode(key, false, false)
end

function input:keyHold(key)
    self:decode(key, true, true)
end

function input:IsPressed(key)
    return self.keyState[key]
end

-- Register a function to be triggered when a key is pressed and certain modifiers are set
function input:Register(key, criteria, func)
    key = EnumName(keys, key)
    local l = self.lookup[key]

    if l == nil then
        l = {}
        self.lookup[key] = l
    end

    table.insert(l, { criteria = criteria, func = func })
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