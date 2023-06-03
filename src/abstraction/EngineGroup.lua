---@class EngineGroup
---@field New fun(...):EngineGroup
---@field Add fun(tag:string)
---@field Intersection fun():string
---@field Union fun():string


local EngineGroup = {}
EngineGroup.__index = EngineGroup

function EngineGroup.New(...)
    local e = {
        tags = {},
        dirty = true,
        intersection = "",
        union = ""
    }

    ---@param name string
    function e.Add(name)
        -- Append at the end of the list
        table.insert(e.tags, #e.tags + 1, name:lower())
        e.intersection = table.concat(e.tags, " ")
        e.union = table.concat(e.tags, ",")
    end

    ---@return string
    function e.Intersection()
        return e.intersection
    end

    ---@return string
    function e.Union()
        return e.union
    end

    function e.__tostring()
        return e.Intersection()
    end

    for _, name in ipairs({ ... }) do
        if name ~= nil then
            e.Add(name)
        end
    end

    return setmetatable(e, EngineGroup)
end

return EngineGroup
