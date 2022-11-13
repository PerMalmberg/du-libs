---A ValueTree works a bit like Json; it allows you to set values in a tree structure.
---@class ValueTree
---@field Set fun(topicPath:string, value:string|number|boolean|nil)
---@field Pick fun():table

local ValueTree = {}
ValueTree.__index = ValueTree

---Creates a new ValueTree
---@return ValueTree
function ValueTree.New()
    local s = {}
    local tree = {}

    ---Sets the value in tree
    ---@param topicPath string A path or just a name, such as a/b or just myValue.
    ---@param value string|number|boolean|nil
    function s.Set(topicPath, value)
        -- Build a tree for the path
        local parts = {}

        for nodeName in string.gmatch(topicPath, "[a-z_]+") do
            table.insert(parts, nodeName)
        end

        if not tree then
            tree = {}
        end

        local curr = tree
        for i, nodeName in ipairs(parts) do
            if i == #parts then
                -- Save the name for the value
                break
            end
            if not curr[nodeName] then
                curr[nodeName] = {}
            end
            curr = curr[nodeName]
        end

        curr[parts[#parts]] = value
    end

    ---Returns the current tree, or nil of no data is available.
    ---@return table|nil
    function s.Pick()
        local old = tree
        tree = nil
        return old
    end

    return setmetatable(s, ValueTree)
end

return ValueTree
