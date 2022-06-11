require("util/Enum")
local typeComp = require("debug/TypeComp")

local log = {}
log.__index = log

log.LogLevel = Enum {
    "OFF",
    "INFO",
    "ERROR",
    "WARNING",
    "DEBUG"
}

function new()
    local o = {
        level = log.LogLevel.ERROR
    }
    return setmetatable(o, log)
end

local function getLevelStr(lvl)
    if lvl == log.LogLevel.DEBUG then
        return "D"
    elseif lvl == log.LogLevel.ERROR then
        return "E"
    elseif lvl == log.LogLevel.INFO then
        return "I"
    elseif lvl == log.LogLevel.WARNING then
        return "W"
    else
        return "UNKOWN"
    end
end

local function formatValues(...)
    local parts = {}

    for _, v in ipairs({ ... }) do
        local s = {}
        if typeComp.IsString(v) then
            s = string.format("%s", v)
        elseif typeComp.IsNumber(v) then
            s = string.format("%s", tonumber(v))
        elseif typeComp.IsVec3(v) then
            s = string.format("vec3(%s, %s, %s)", v.x, v.y, v.z)
        elseif typeComp.IsBoolean(v) then
            s = tostring(v)
        else
            s = "Unsupported table type:" .. type(v)
        end

        table.insert(parts, #parts + 1, string.format(" %s", s))
    end

    return table.concat(parts)
end

function log:print(level, msg, ...)
    if self.level >= level then
        local extra = {...}
        if #extra == 0 then
            system.print(string.format("[%s] %s", getLevelStr(level), msg))
        else
            system.print(string.format("[%s] %s:%s", getLevelStr(level), msg, formatValues(...)))
        end
    end
end

function log:SetLevel(level)
    self.level = level
end

function log:Info(msg, ...)
    self:print(log.LogLevel.INFO, msg, ...)
end

function log:Warning(msg, ...)
    self:print(log.LogLevel.WARNING, msg, ...)
end

function log:Error(msg, ...)
    self:print(log.LogLevel.ERROR, msg, ...)
end

function log:Debug(msg, ...)
    self:print(log.LogLevel.DEBUG, msg, ...)
end

local singleton = nil

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                if singleton == nil then
                    singleton = new()
                end
                return singleton
            end
        }
)