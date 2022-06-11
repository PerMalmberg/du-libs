local utc = system.getUtcTime
local utcOffset = system.getUtcOffset
local ark = system.getArkTime
local _24hInSeconds = 24 * 3600

local singleton = nil
local clock = {}
clock.__index = clock

local function new()
    local t = {}
    return setmetatable(t, clock)
end

function clock:calc(now, offset)
    if offset ~= nil then
        now = now + offset
    end

    o = {}
    o.day = math.floor(now / _24hInSeconds)
    now = now % _24hInSeconds
    o.hour = math.floor(now / 3600)
    now = now % 3600
    o.minute = math.floor(now / 60)
    now = now % 60
    o.second = math.floor(now)
    return o
end

function clock:Local()
    return self:UTC(utc, utcOffset())
end

function clock:Utc()
    return self:calc(utc())
end

function clock:Ark()
    return self:UTC(ark())
end

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