local log = require("debug/Log")()
local Enum = require("util/Enum")

local argType = Enum {
    "BOOLEAN",
    "NUMBER",
    "STRING",
}

function argType.parseValue(wantedType, raw)
    if wantedType == argType.BOOLEAN then
        if raw == "true" or raw == "1" then
            return true
        elseif raw == "false" or raw == "0" then
            return false
        else
            log:Error("Not a boolean", raw)
        end
    elseif wantedType == argType.NUMBER then
        local match = string.match(raw, "(%d*%.?%d+)")
        if match == nil then
            log:Error("Not a number:", raw)
            return nil
        else
            return tonumber(match)
        end
    else
        return raw
    end
end

return argType