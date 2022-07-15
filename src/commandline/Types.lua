local log = require("debug/Log")()
local Enum = require("util/Enum")

local argType = Enum {
    "EMPTY",
    "BOOLEAN",
    "NUMBER",
    "STRING",
}

--- @return tuple of boolean,value, where the boolean indicates if the value was parsed.
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
            return false, nil
        else
            return true, tonumber(match)
        end
    else
        return true, raw
    end
end

return argType