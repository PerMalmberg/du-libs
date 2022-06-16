local keys = require("input/Keys")

local criteria = {}
criteria.__index = criteria

local function new()
    local o = {
        requiredMods = {},
        onRepeat = false,
        onPress = false,
        onRelease = false,
    }

    setmetatable(o, criteria)

    return o
end

function criteria:Matches(input, isRepeat, isPressed)
    if (isRepeat and not self.onRepeat) then
        return false
    elseif not isRepeat then

        if (not self.onPress and not self.onRelease) then
            return false
        end

        if not ((self.onPress and isPressed) or (self.onRelease and not isPressed)) then
            return false
        end
    end

    for _, k in pairs(self.requiredMods) do
        if not input:IsPressed(k) then
            return false
        end
    end

    return true
end

function criteria:__tostring()
    local s = ""
    for _, c in pairs(self.requiredMods) do
        s = s .. " " .. c
    end

    return "Criteria:" .. s
end

function criteria:LShift()
    table.insert(self.requiredMods, EnumName(keys, keys.lshift))
    return self
end

function criteria:LCtrl()
    table.insert(self.requiredMods, EnumName(keys, keys.brake))
    return self
end

function criteria:LAlt()
    table.insert(self.requiredMods, EnumName(keys, keys.lalt))
    return self
end

function criteria:OnPress()
    self.onPress = true
    return self
end

function criteria:OnRelease()
    self.onRelease = true
    return self
end

function criteria:OnRepeat()
    self.onRepeat = true
    return self
end

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                return new(...)
            end
        }
)