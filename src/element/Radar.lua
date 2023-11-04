local log = require("debug/Log").Instance()

---@class RadarControl
---@field Instance fun():RadarControl
---@field Show fun(on:boolean)
---@field Sort fun(method:integer)
---@field IsVisible fun():boolean
---@field NextMethod fun()

local RadarControl = {}
RadarControl.__index = RadarControl


---@enum RadaraState
RadarState = {
    Operational = 1,
    Broken = 0,
    BadEnvironment = -1,
    Obstructed = -2,
    AlreadyInUse = -3
}

local radarSortMethod = {
    "Distance acending",
    "Distance descending",
    "Size ascending",
    "Size descending",
    "Threat ascending",
    "Threat descending"
}

local radarSortCount = TableLen(radarSortMethod)

local atmoRadars = { "RadarPvPAtmospheric" }
local spaceRadars = { "RadarPVPSpaceSmallGroup", "RadarPVPSpaceMediumGroup", "RadarPVPSpaceLargeGroup" }

---@param names string[]
---@return Radar
local function getRadar(names)
    local r = nil
    for _, n in ipairs(names) do
        r = r or library.getLinkByClass(n)
    end

    return r
end

local instance ---@type RadarControl

---@return RadarControl
function RadarControl.Instance()
    if instance then return instance end

    local s = {}
    local showRadar = false
    local sortMethod = 1

    ---@type Radar[]
    local radars = { getRadar(atmoRadars), getRadar(spaceRadars) }

    local count = radars[1] ~= nil and 1 or 0
    count = count + (radars[2] ~= nil and 1 or 0)

    local function update()
        for _, r in ipairs(radars) do
            if r then
                if not showRadar or r.getOperationalState() == RadarState.BadEnvironment then
                    r.hideWidget()
                else
                    r.showWidget()
                end
            end
        end
    end

    ---@param on boolean
    function s.Show(on)
        showRadar = on
        log.Info("Radar ", on and "shown" or "hidden")
        if on then
            s.Sort(sortMethod)
        end
    end

    ---@return boolean
    function s.IsVisible()
        return showRadar
    end

    function s.NextMethod()
        local next = (sortMethod + 1) % (radarSortCount + 1)
        if next == 0 then
            next = 1
        end
        s.Sort(next)
    end

    ---@param method integer
    function s.Sort(method)
        sortMethod = method
        for _, r in ipairs(radars) do
            if r and r.getSortMethod() ~= radars then
                if r.setSortMethod(sortMethod) then
                    log.Error("Sort method set to ", radarSortMethod[sortMethod])
                end
            end
        end
    end

    system:onEvent("onUpdate", update)

    instance = setmetatable(s, RadarControl)
    return instance
end

return RadarControl
