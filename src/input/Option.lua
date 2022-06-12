local log = require("debug/Log")()
local argType = require("input/Types")

local option = {}
option.__index = option

local function new(name)
    local o = {
        name = name,
        sanitizedName = name:gsub("^%-*", ""),
        type = nil,
        mandatory = false
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

function option:Parse(args, target)
    -- Find the argument in the input data
    for i, key in ipairs(args) do

        if key == self.name then
            log:Debug("Found", key)
            -- Next value is the argument, if it exists
            if i + 1 <= #args then
                table.remove(args, i) -- Remove the arg itself
                local v = table.remove(args, i) -- Remove and store the value
                log:Debug("Value", v)

                if self.type == argType.BOOLEAN then
                    log:Debug("Boolean", v)
                    if v == "true" or v == "1" then
                        target[self.sanitizedName] = true
                    elseif v == "false" or v == "0" then
                        target[self.sanitizedName] = false
                    end
                elseif self.type == argType.NUMBER then
                    log:Debug("Number", v)
                    local match = string.match(v, "(%d*%.?%d+)")
                    if match == nil then
                        log:Error(v, "is not a number")
                    else
                        log:Debug("Match", match)
                        target[self.sanitizedName] = tonumber(match)
                    end
                else
                    log:Debug("String", v)
                    target[self.sanitizedName] = v
                end
            elseif self.mandatory then
                log:Error("Missing value for mandatory option ", k)
                return false
            end

            break
        end
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