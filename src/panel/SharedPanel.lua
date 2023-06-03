local Panel = require("panel/Panel")

---@class SharedPanel
---@field Instance fun():SharedPanel
---@field Get fun(title:string):Panel
---@field Close fun(title:string)

local singleton = nil

local SharedPanel = {}
SharedPanel.__index = SharedPanel

---@return SharedPanel
function SharedPanel.Instance()
    if singleton then return singleton end
    local s = {}
    local panels = {}

    function s.Close(title)
        local p = panels[title]
        if p ~= nil then
            p:Close()
            panels[title] = nil
        end
    end

    function s.Get(title)
        if panels[title] == nil then
            panels[title] = Panel.New(title)
        end

        return panels[title]
    end

    singleton = setmetatable(s, SharedPanel)
    return s
end

return SharedPanel
