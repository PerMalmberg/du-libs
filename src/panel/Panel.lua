local ValueWidget = require("panel/ValueWidget")

---@class Panel
---@field New fun(title:string):Panel
---@field Close fun()
---@field Clear fun()
---@field Update fun()
---@field CreateValue fun(title?:string, unit?:string)

local Panel = {}
Panel.__index = Panel

---@param title string
---@return Panel
function Panel.New(title)
    local s = {
        panelId = system.createWidgetPanel(title),
        widgets = {},
        updateHandlerId = nil
    }

    function s.Close()
        system:clearEvent("update", s.updateHandlerId)

        s.Clear()

        system.destroyWidgetPanel(s.panelId)
    end

    function s.Clear()
        for _, widget in pairs(s.widgets) do
            widget:Close()
        end
        s.widgets = {}
    end

    function s.CreateValue(valueTitle, unit)
        local w = ValueWidget.New(s.panelId, valueTitle or "", unit or "")
        s.widgets[w.WidgetId()] = w
        return w
    end

    function s.Update()
        for _, widget in pairs(s.widgets) do
            widget.Update()
        end
    end

    s.updateHandlerId = system:onEvent("onUpdate", s.Update, s)
    return setmetatable(s, Panel)
end

return Panel
