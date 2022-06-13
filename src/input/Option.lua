local log = require("debug/Log")()
local argType = require("input/Types")

local option = {}
option.__index = option

local function new(name)
    local o = {
        name = name,
        sanitizedName = name:gsub("^%-*", ""),
        type = nil,
        mandatory = false,
        default = nil
    }

    return setmetatable(o, option)
end

function option:AsString()
    self.type = argType.STRING
    return self
end

function option:AsNumber()
    self.type = argType.NUMBER
    return self
end

function option:AsBoolean()
    self.type = argType.BOOLEAN
    return self
end

function option:Mandatory()
    self.mandatory = true
    return self
end

function option:Default(v)
    self.default = v
end

function option:Parse(args, target)
    -- Find the argument in the input data
    for i, key in ipairs(args) do

        if key == self.name then
            -- Next value is the argument, if it exists
            if i + 1 <= #args then
                table.remove(args, i) -- Remove the arg itself
                local v = table.remove(args, i) -- Remove and store the value

                if self.type == argType.BOOLEAN then
                    if v == "true" or v == "1" then
                        target[self.sanitizedName] = true
                    elseif v == "false" or v == "0" then
                        target[self.sanitizedName] = false
                    end
                elseif self.type == argType.NUMBER then
                    local match = string.match(v, "(%d*%.?%d+)")
                    if match == nil then
                        log:Error("Not a number:", v)
                    else
                        target[self.sanitizedName] = tonumber(match)
                    end
                else
                    target[self.sanitizedName] = v
                end
            elseif self.mandatory then
                log:Error("Missing value for mandatory option ", key)
                return false
            end

            break
        end
    end

    if target[self.sanitizedName] == nil and self.default ~= nil then
        target[self.sanitizedName] = self.default
    end

    local res = (not self.mandatory) or target[self.sanitizedName] ~= nil

    if not res then
        log:Error("Option", self.name, "not complete")
    end
    return res
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