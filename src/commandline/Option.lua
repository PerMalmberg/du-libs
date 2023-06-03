local log = require("debug/Log").Instance()
local argType = require("commandline/Types")

---@class Option
---@field New fun(name:string):Option
---@field AsString fun():Option
---@field AsNumber fun():Option
---@field AsBoolean fun():Option
---@field AsEmptyBoolean fun():Option
---@field Mandatory fun():Option
---@field Default fun(v:ArgumentValueTypes):Option
---@field Parse fun(args:string[], target:table<string,ArgumentValueTypes>):boolean

local Option = {}
Option.__index = Option

---Creates a new command option
---@param name string The option name, such as "-opt", "--opt" or just "opt". Im the latter case a "-" is added to the name.
---@return Option
function Option.New(name)
    if name:sub(1, 1) ~= "-" then
        name = "-" .. name
    end

    local s = {} ---@type Option
    local sanitizedName = name:gsub("^%-*", "")
    local optType = nil
    local mandatory = false
    local default = nil

    ---Marks option to be a string
    ---@return Option
    function s.AsString()
        optType = argType.STRING
        return s
    end

    ---Mark option as number
    ---@return Option
    function s.AsNumber()
        optType = argType.NUMBER
        return s
    end

    ---Mark option as boolean
    ---@return Option
    function s.AsBoolean()
        optType = argType.BOOLEAN
        return s
    end

    ---Mark option as mandatory
    ---@return Option
    function s.Mandatory()
        mandatory = true
        return s
    end

    ---Mark option as empty
    ---@return Option
    function s.AsEmptyBoolean()
        optType = argType.EMPTY_BOOLEAN
        return s
    end

    ---Set default value for option
    ---@param v ArgumentValueTypes
    function s.Default(v)
        default = v
        return s
    end

    ---Parses the arguments, putting the found values in the the target in a key:value fashion, with sanitized key names.
    ---@param args string[]
    ---@param target table<string, ArgumentValueTypes>
    ---@return boolean
    function s.Parse(args, target)
        -- Find the argument in the input data
        for i, key in ipairs(args) do
            if key == name then
                if optType == argType.EMPTY_BOOLEAN then
                    target[sanitizedName] = true
                    table.remove(args, i)
                elseif i + 1 <= #args then          -- Next value is the argument, if it exists
                    table.remove(args, i)           -- Remove the arg itself
                    local v = table.remove(args, i) -- Remove and store the value

                    local ok
                    ok, target[sanitizedName] = argType.parseValue(optType, v)
                    if not ok then
                        return false
                    end
                elseif mandatory then
                    log.Error("Missing value for mandatory option ", key)
                    return false
                end

                break
            end
        end

        if optType == argType.EMPTY_BOOLEAN and target[sanitizedName] == nil then
            target[sanitizedName] = false
        end

        if target[sanitizedName] == nil and default ~= nil then
            target[sanitizedName] = default
        end

        local res = (not mandatory) or target[sanitizedName] ~= nil

        if not res then
            log.Error("Option", name, "not complete")
        end
        return res
    end

    return setmetatable(s, Option)
end

return Option
