local log = require("debug/Log")()

---@alias ArgumentValueTypes nil|boolean|number|string

---@enum ArgTypes
local argType = {
    BOOLEAN = 1,
    NUMBER = 2,
    STRING = 3,
    EMPTY_BOOLEAN = 4
}

---Parses the raw input returning status, value
---@param wantedType ArgTypes
---@param raw string
---@return boolean, ArgumentValueTypes
function argType.parseValue(wantedType, raw)
    if wantedType == argType.EMPTY and raw == nil then
        return true, ""
    elseif raw == nil then
        return true, raw
    end

    if wantedType == argType.BOOLEAN then
        if raw == "true" or raw == "1" then
            return true, true
        elseif raw == "false" or raw == "0" then
            return true, false
        else
            log:Error("Not a boolean: ", raw)
        end
    elseif wantedType == argType.NUMBER then
        local match = string.match(raw, "([+-]?%d*%.?%d+)")
        if match == nil then
            log:Error("Not a number: ", raw)
        else
            return true, tonumber(match)
        end
    else
        return true, raw
    end

    return false, nil
end

return argType
