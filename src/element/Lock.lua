local SU = require("util/StringUtil")
local log = require("debug/Log")()

---@enum EngineType
EngineType = {
    NOT_ENGINE = 0,
    ATMO = 1,
    SPACE = 2,
    ROCKET = 3
}

---@enum EngineSize
EngineSize = {
    XS = 1,
    S = 2,
    M = 3,
    L = 4,
    XL = 5
}

---@alias EngineLimits table<EngineType, table<EngineSize, number>>


---@param lowerName string
---@return EngineSize
local function getSize(lowerName)
    if SU.EndsWith(lowerName, " xs") then return EngineSize.XS end
    if SU.EndsWith(lowerName, " s") then return EngineSize.S end
    if SU.EndsWith(lowerName, " m") then return EngineSize.M end
    if SU.EndsWith(lowerName, " l") then return EngineSize.L end
    return EngineSize.XL
end

---@param lowerName string
---@return EngineType
local function getType(lowerName)
    if lowerName:match("atmospheric engine") then
        return EngineType.ATMO
    elseif lowerName:match("space engine") then
        return EngineType.SPACE
    elseif lowerName:match("rocket engine") then
        return EngineType.ROCKET
    end

    return EngineType.NOT_ENGINE
end

---@param t EngineType
local function typeStr(t)
    if t == EngineType.ATMO then return "Atmospheric" end
    if t == EngineType.ROCKET then return "Rocket" end
    return "Space"
end

---@param s EngineSize
---@return string
local function sizeStr(s)
    if s == EngineSize.XS then return "XS" end
    if s == EngineSize.S then return "S" end
    if s == EngineSize.M then return "M" end
    if s == EngineSize.L then return "L" end
    return "XL"
end

---@class ElementLock
---@field New fun():ElementLock
---@field AddLimit fun(count:number, size:EngineSize, engineType:EngineType)
---@field ValidateCo fun():boolean
---@field NoLimit fun()

local Lock = {}
Lock.__index = Lock

function Lock.New()
    local noLimit = math.mininteger
    local s = {}
    local limits = {} ---@type EngineLimits
    local atmo = {} ---@type table<EngineSize, number>
    limits[EngineType.ATMO] = atmo
    local space = {} ---@type table<EngineSize, number>
    limits[EngineType.SPACE] = space
    local rocket = {} ---@type table<EngineSize, number>
    limits[EngineType.ROCKET] = rocket

    -- Default with none allowed
    for i = EngineSize.XS, EngineSize.XL, 1 do
        atmo[i] = 0
        space[i] = 0
        rocket[i] = 0
    end

    ---Sets a limit for the number of engines allowed of the given type and size
    ---@param engineType EngineType
    ---@param size EngineSize
    ---@param count integer
    function s.AddLimit(engineType, size, count)
        limits[engineType][size] = count
    end

    ---@return boolean
    function s.ValidateCo()
        local res = true

        local core = library.getCoreUnit()
        for _, localId in ipairs(core.getElementIdList()) do
            local id = core.getElementItemIdById(localId)
            local item = system.getItem(id)
            local withSize = item.displayNameWithSize:lower() ---@type string

            local t = getType(withSize)
            local size = getSize(withSize)

            if t ~= EngineType.NOT_ENGINE then
                local limit = limits[t]
                if limit[size] ~= noLimit then
                    limit[size] = limit[size] - 1
                end
            end

            coroutine.yield()
        end

        -- Any engine that has a count of less than 0 there are to many of
        for t = EngineType.ATMO, EngineType.ROCKET do
            for size = EngineSize.XS, EngineSize.XL do
                local count = limits[t][size]
                if count ~= noLimit and count < 0 then
                    log:Error(math.abs(count), " too many engines of type: ", typeStr(t), " ", sizeStr(size))
                    res = false
                end
            end
            coroutine.yield()
        end

        return res
    end

    return setmetatable(s, Lock)
end

return Lock
