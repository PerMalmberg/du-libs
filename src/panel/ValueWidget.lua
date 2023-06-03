---@class ValueWidget
---@field New fun(panelId:string, title:string, unit:string):ValueWidget
---@field Close fun()
---@field Set fun(value:any)
---@field Update fun()
---@field WidgetId fun():string

local ValueWidget = {}
ValueWidget.__index = ValueWidget

---@param panelId string
---@param title string
---@param unit string
---@return ValueWidget
function ValueWidget.New(panelId, title, unit)
    local s = {
        panelId = panelId,
        title = title,
        unit = unit,
        widgetId = system.createWidget(panelId, "value"),
        dataId = nil,
        newValue = nil
    }

    if s.widgetId == nil then
        system.print("Could not create widget!")
        unit.exit()
    end

    function s.Close()
        system.removeDataFromWidget(s.dataId, s.widgetId)
        system.destroyData(s.dataId)
        system.destroyWidget(s.widgetId)
    end

    function s.Set(value)
        s.newValue = tostring(value)
    end

    function s.Update()
        if s.newValue ~= nil then
            local str = '{ "label":"' ..
                s.title .. '", "value": "' .. s.newValue .. '", "unit": "' .. s.unit .. '"}'

            if s.dataId == nil then
                system.destroyData(s.dataId)
                s.dataId = system.createData(str)
                system.addDataToWidget(s.dataId, s.widgetId)
            else
                system.updateData(s.dataId, str)
            end

            s.newValue = nil
        end
    end

    function s.WidgetId()
        return s.widgetId
    end

    setmetatable(s, ValueWidget)
    return s
end

return ValueWidget
