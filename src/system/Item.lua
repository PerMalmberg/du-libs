---@class Item
---@field New fun(core:CoreUnit):Item
---@field FilterItemsByName fun(...):table[]

local Item = {}
Item.__index = Item
function Item.New(core)
    local s = {}

    -- Returns the list of items on the construct which has all the given name parts.
    function s.FilterItemsByName(...)
        local items = {}
        for _, lid in ipairs(core.getElementIdList()) do
            local info = system.getItem(core.getElementItemIdById(lid))
            local l = info.name:lower()
            local terms = { ... }
            local count = 0

            for _, part in ipairs(terms) do
                if string.find(l, part, 1, true) then
                    count = count + 1
                else
                    break
                end
            end

            if count == #terms then
                items[#items + 1] = info
                system.print(info.name)
            end
        end

        return items
    end

    return setmetatable(s, Item)
end

return Item
