local ValueWidget = require("panel/ValueWidget")

---@class Panel
---@field Close fun(self:Panel)
---@field Clear fun(self:Panel)
---@field Update fun(self:Panel)
---@field CreateValue fun(self:Panel, title?:string, unit?:string)

local panel = {}
panel.__index = panel

local function new(title)
    local instance = {
        title = title,
        panelId = system.createWidgetPanel(title),
        widgets = {},
        updateHandlerId = nil
    }

    setmetatable(instance, panel)

    instance.updateHandlerId = system:onEvent("onUpdate", instance.Update, instance)

    return instance
end

function panel:Close()
    system:clearEvent("update", self.updateHandlerId)

    self:Clear()

    system.destroyWidgetPanel(self.panelId)
end

function panel:Clear()
    for _, widget in pairs(self.widgets) do
        widget:Close()
    end
    self.widgets = {}
end

function panel:CreateValue(title, unit)
    local w = ValueWidget(self.panelId, title or "", unit or "")
    self.widgets[w.widgetId] = w
    return w
end

function panel:Update()
    for _, widget in pairs(self.widgets) do
        widget:Update()
    end
end

return setmetatable(
    {
        new = new
    },
    {
        __call = function(_, ...)
            return new(...)
        end
    }
)
