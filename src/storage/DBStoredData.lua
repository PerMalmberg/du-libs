local json = require("json")

local function findAnyFunction(o)
    if type(o) ~= "table" then
        return nil
    end

    local found = nil

    for key, value in pairs(o) do
        local t = type(value)

        if t == "function" then
            return key
        else
            found = findAnyFunction(value)
        end

        if found then
            return found
        end
    end

    return found
end

---@class DBStoredData
---@field value string|number|table The data to save
---@field valueType string The type of data held
---@field dirty boolean True if it should be marked as dirty
---@field Persist fun():table Returns an opaque table to serialize for storage. Also marks the item as clean.
local DBStoredData = {}
DBStoredData.__index = DBStoredData

function DBStoredData.New(value, dirty)
    local t = type(value)
    local foundFunctionName = findAnyFunction(value)
    if foundFunctionName then
        error(string.format("Functions not allowed in PODs: '%s'", foundFunctionName))
    end

    local s = {
        valueType = t,
        value = value,
        dirty = dirty or false
    }

    function s.Persist()
        s.dirty = false
        local str = json.encode(
            {
                t = s.valueType,
                v = s.value
            })
        return str
    end

    return setmetatable(s, DBStoredData)
end

---Creates a new DBStoreData from data read from databank
---@param readData string
---@return DBStoredData|nil
function DBStoredData.NewFromDB(readData)
    if readData ~= nil then
        local decoded

        -- Suppress decoding errors
        xpcall(function()
            decoded = json.decode(readData)
        end, traceback)

        if decoded ~= nil
            and type(decoded) == "table"
            and decoded.t
            and decoded.v ~= nil -- must check against nil, as v may be boolean 'false'
        then
            return DBStoredData.New(decoded.v)
        end
    end

    return nil
end

return DBStoredData
