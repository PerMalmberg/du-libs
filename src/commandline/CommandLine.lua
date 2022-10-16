local log = require("debug/Log")()
local su = require("util/StringUtil")
local Command = require("commandline/Command")

---@alias CommandFunction fun(data:CommandResult)
---@alias PreparedCommand {cmd:Command, exec:CommandFunction}

---@class CommandLine
---@field Accept fun(name:string, func:CommandFunction):Command
---@field Clear fun()

local CommandLine = {}
CommandLine.__index = CommandLine
local singleton

---Get the commandline instance
---@return CommandLine
function CommandLine.Instance()
    if singleton then
        return singleton
    end

    local s = {}
    local command = {} ---@type table<string, PreparedCommand>

    ---Accepts a command
    ---@param name string
    ---@param func CommandFunction
    ---@return Command
    function s.Accept(name, func)
        local o = Command.New()
        command[name] = { cmd = o, exec = func }
        return o
    end

    ---Clears all registered commands
    function s.Clear()
        command = {}
    end

    ---Parses and executes the input command
    ---@param input string
    local function exec(input)
        local exeFunc = function(commandString)
            local parts = su.SplitQuoted(commandString)
            -- We now have each part of the command in an array, where the first part is the command itself.
            local possibleCmd = table.remove(parts, 1)
            local preparedCommand = command[possibleCmd]
            if preparedCommand == nil then
                log:Error("Command not supported:", possibleCmd)
            else
                -- Let the command parse the rest of the arguments. If successful, we get back a table with the values as per the options.
                -- The command-value itself may be empty if it is not mandatory.
                local data = preparedCommand.cmd.Parse(parts)
                if data == nil then
                    log:Error("Cannot execute:", commandString)
                else
                    log:Debug("Executing:", commandString)
                    preparedCommand.exec(data)
                end
            end
        end

        local status, ret = xpcall(exeFunc, traceback, input)
        if not status then
            log:Error(ret)
        end
    end

    ---Receiver of input from the lua chat
    ---@param cmdLine CommandLine
    ---@param text string
    function s.inputText(cmdLine, text)
        exec(text)
    end

    singleton = setmetatable(s, CommandLine)

    system:onEvent("onInputText", s.inputText, s)
    return singleton
end

return CommandLine
