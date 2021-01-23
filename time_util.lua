TimeUtil = {}

function TimeUtil.getTime(value)
    o = {}
    local now = value or system.getTime()
    o.day = math.floor(now / (24*3600))
    now = now % (24 * 3600)
    o.hour = math.floor(now / 3600)
    now = now % 3600
    o.minute = math.floor(now / 60)
    now = now % 60
    o.second = math.floor(now)
    return o
end

function TimeUtil.getClientTime()
    return system.getTime()
end