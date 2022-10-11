local log = require("debug/Log")()
local Option = require("commandline/Option")
local argType = require("commandline/Types")

---@module "commandline/Types"

---@alias CommandResult table<string, ArgumentValueTypes> -- Actual layout: {commandValue:value, sanitizedName:optionValue}

---@class Command
---@field New fun():Command
---@field AsString fun():Command
---@field AsNumber fun():Command
---@field AsBoolean fun():Command
---@field AsEmpty fun():Command
---@field Mandatory fun():Command
---@field Option fun(name:string):Option
---@field Parse fun(args:string):CommandResult

local Command = {}
Command.__index = Command

function Command.New()
    local s = {} ---@type Command
    local type = argType.EMPTY
    local option = {} ---@type table<string,Option>
    local mandatory = false

    ---Marks command as string
    ---@return Command
    function s.AsString()
        type = argType.STRING
        return s
    end

    ---Marks command as number
    ---@return Command
    function s.AsNumber()
        type = argType.NUMBER
        return s
    end

    ---Marks command as boolean
    ---@return Command
    function s.AsBoolean()
        type = argType.BOOLEAN
        return s
    end

    ---Marks command as emtpy
    ---@return Command
    function s.AsEmpty()
        if mandatory then
            error("Command is mandatory, cannot set as type empty")
        end
        type = argType.EMPTY
        return s
    end

    ---Marks command as mandatory
    ---@return Command
    function s.Mandatory()
        if type == argType.EMPTY then
            error("Command is of type empty, cannot set as mandatory")
        end
        mandatory = true
        return s
    end

    ---Adds an option to the command
    ---@param name string
    ---@return Option
    function s.Option(name)
        local opt = Option.New(name)
        option[name] = opt
        return opt
    end

    ---Parses command and options from args
    ---@param args string[]
    ---@return CommandResult|nil
    function s.Parse(args)
        -- Let the options extract their data first; whatever is left is for the command
        local data = {} ---@type CommandResult

        for _, option in pairs(option) do
            if not option.Parse(args, data) then
                return nil
            end
        end

        local ok
        ok, data.commandValue = argType.parseValue(type, args[1])

        if not ok then
            return nil
        end

        if data.commandValue == nil and mandatory then
            log:Error("Missing mandatory value for command")
            return nil
        end

        return data
    end

    return setmetatable(s, Command)
end

return Command
