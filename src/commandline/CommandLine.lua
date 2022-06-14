local log = require("debug/Log")()
local su = require("util/StringUtil")
local Command = require("commandline/Command")

local input = {}
input.__index = input

local function new()
    local o = {
        command = {}
    }

    setmetatable(o, input)

    system:onEvent("inputText", o.inputText, o)

    return o
end

function input.inputText(inp, text)
    inp:Exec(text)
end

function input:Accept(command, func)
    local o = Command()
    self.command[command] = { cmd = o, exec = func }
    return o
end

function input:Exec(command)
    local parts = su.SplitQuoted(command)
    -- We now have each part of the command in an array, where the first part is the command.
    local possibleCmd = table.remove(parts, 1)
    local cmd = self.command[possibleCmd]
    if cmd == nil then
        log:Error("Command not supported:", possibleCmd)
    else
        -- Let the command parse the rest of the arguments. If successful, we get back a table with the values as per the options.
        -- The command-value itself may be empty if it is not mandatory.
        local data = cmd.cmd:Parse(parts)
        if data == nil then
            log:Error("Cannot execute:", command)
        else
            log:Debug("Executing:", command)
            cmd.exec(data)
        end
    end
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