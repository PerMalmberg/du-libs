---@class Log
---@field Instance fun():Log
---@field SetLevel fun(level:LogLevel)
---@field Info fun(...:any)
---@field Warning fun(...:any)
---@field Error fun(...:any)
---@field Debug fun(...:any)

local Log = {}
Log.__index = Log

---@enum LogLevel
LVL = {
    OFF = 0,
    INFO = 2,
    ERROR = 3,
    WARNING = 4,
    DEBUG = 5
}

local instance ---@type Log

---@return Log
function Log.Instance()
    if instance then return instance end
    local s = {}
    local level = LVL.WARNING

    local function getLevelStr(lvl)
        if lvl == LVL.DEBUG then
            return "D"
        elseif lvl == LVL.ERROR then
            return "E"
        elseif lvl == LVL.INFO then
            return "I"
        elseif lvl == LVL.WARNING then
            return "W"
        else
            return "UNKOWN"
        end
    end

    local function formatValues(...)
        local parts = {}
        local args = { ... }

        for i = 1, #args, 1 do
            local v

            v = args[i]
            if v == nil then
                v = ""
            end

            local r = ""

            local t = type(v)
            if t == "string" then
                r = string.format("%s", v)
            elseif t == "number" then
                r = string.format("%s", tonumber(v))
            elseif t == "boolean" then
                r = tostring(v)
            elseif t == "function" then
                r = tostring(v)
            elseif t == "table" then
                r = "{"
                for key, data in pairs(v) do
                    r = r .. formatValues(key, ": ", data, ",")
                end
                r = r .. "}"
            else
                r = "unprintable: '" .. t .. "'"
            end

            parts[#parts + 1] = string.format("%s", r)
        end

        return table.concat(parts)
    end

    function s.print(logLevel, ...)
        if logLevel >= level then
            system.print(string.format("[%s] %s", getLevelStr(logLevel), formatValues(...)))
        end
    end

    ---@param logLevel LogLevel
    function s.SetLevel(logLevel)
        level = logLevel
    end

    ---@param msg any
    ---@param ... any
    function s.Info(msg, ...)
        s.print(LVL.INFO, msg, ...)
    end

    ---comment
    ---@param msg any
    ---@param ... any
    function s.Warning(msg, ...)
        s.print(LVL.WARNING, msg, ...)
    end

    ---@param msg any
    ---@param ... any
    function s.Error(msg, ...)
        s.print(LVL.ERROR, msg, ...)
    end

    ---@param msg any
    ---@param ... any
    function s.Debug(msg, ...)
        s.print(LVL.DEBUG, msg, ...)
    end

    return setmetatable(s, Log)
end

return Log
