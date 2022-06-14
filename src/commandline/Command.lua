local log = require("debug/Log")()
local Option = require("commandline/Option")
local argType = require("commandline/Types")

local command = {}
command.__index = command

local function new()
    local o = {
        type = nil,
        mandatory = false,
        option = {}
    }

    return setmetatable(o, command)
end

function command:AsString()
    self.type = argType.STRING
    return self
end

function command:AsNumber()
    self.type = argType.NUMBER
    return self
end

function command:AsBoolean()
    self.type = argType.BOOLEAN
    return self
end

function command:Mandatory()
    self.mandatory = true
    return self
end

function command:Option(name)
    local opt = Option(name)
    self.option[name] = opt
    return opt
end

function command:Parse(args)
    -- Let the options extract their data first; whatever is left is for the command itself.
    local data = {}

    for _, option in pairs(self.option) do
        if not option:Parse(args, data) then
            return nil
        end
    end

    data.commandValue = args[1]
    if data.commandValue == nil and self.mandatory then
        log:Error("Missing mandatory value for command")
        return nil
    end

    return data
end

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                return new()
            end
        }
)