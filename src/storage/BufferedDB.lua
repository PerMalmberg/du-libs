local json = require("dkjson")
local CoRunner = require("system/CoRunner")
local log = require("debug/Log")()
require("util/Table")


local function findAnyFunction(o)
    local found = false
    
    for _, value in pairs(o) do
        local t = type(value)
        
        if t == "function" then
            found = true
        elseif t == "table" then
            found = findAnyFunction(value)
        end

        if found then break end
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

    local s = {
        valueType = t,
        dirty = dirty or false
    }

    if t == "number" then
        s.value = tonumber(value)
    elseif t == "string" then
        s.value = value
    elseif t == "table" then
        s.value = value
        if findAnyFunction(value) then
            error("Cannot store tables with functions")
        end
    else
        error("Can't store values of type " .. t)
    end

    function s:Persist()
        s.dirty = false
        return {
            t = s.value,
            v = s.value
        }
    end

    return setmetatable(s, DBStoredData)
end

---Creates a new DBStoreData from data read from databank
---@param readData table
---@return DBStoredData|nil
function DBStoredData.NewFromDB(readData)
    if readData ~= nil and type(readData) == "table" and readData.t and readData.d then
        return DBStoredData.New(readData)
    end
    return nil
end

---@class BufferedDB
---@field BeginLoad fun(_:table) Starts loading keys into memory
---@field Clear fun(_:table) Clears the databank
---@field IsLoaded fun(_:table):boolean Returns true when all keys have been loaded.
---@field IsDirty fun(_:table):boolean Returns true when a key has not yet been persisted
---@field Get fun(_:table, key:string, default):number|string|table Returns the value of the key, or the default value
---@field Put fun(_:table, key:string, data:number|string|table) Stores the data in key. data can be string, number or (plain data) table.

local BufferedDB = {}
BufferedDB.__index = BufferedDB

---Creates a new BufferedDB
---@param databank table The link to the the databank element we're expecting to be connected to. 
---@return BufferedDB
function BufferedDB.New(databank)
    if type(databank) ~= "table" or databank.getStringValue == nil then
        error("databank parameter of BufferedDB.New must be a link to a databank")
    end

    local s = {}

    local buffer = {} ---@type {[string]:DBStoredData}
    local db = databank
    local loaded = false
    local dirtyCount = 0
    local coRunner = CoRunner(0.1)

    local function persist()
        while true do
            coroutine.yield()
            if s:IsDirty() then
                local i = 0
                for key, data in pairs(buffer) do
                    if i % 5 == 0 then
                        coroutine.yield()
                    end

                    if data.dirty then
                        local v = data.value
                        local str = json.encode({ t = type(v), d = v })
                        db.setStringValue(key, str)
                        buffer[key].dirty = false
                        dirtyCount = dirtyCount - 1
                    end
                    i = i + 1
                end
            end
        end
    end

    ---Begins loading keys
    function BufferedDB:BeginLoad()
        if db == nil then
            error("No databank")
        end

        coRunner:Execute(
                function()
                    local keys = db.getKeyList()
                    for i, k in ipairs(keys) do
                        local data = json.decode(db.getStringValue(k))
                        -- We always expect a table here, if we don't get that, then the data isn't written by this class
                        ---@cast data table
                        local d = DBStoredData.NewFromDB(data)

                        if d then
                            buffer[k] = d
                        end

                        -- Load X keys at a time
                        if i % 10 == 0 then
                            coroutine.yield()
                        end
                    end
                end,
                function()
                    log:Info(TableLen(buffer) .. " keys loaded from data bank'")
                    loaded = true
                    coRunner:Execute(function()
                        persist()
                    end)
                end)
    end

    function BufferedDB:Clear()
        if not loaded then
            error("Call to Clear before loading is completed")
        end

        buffer = {}
        dirtyCount = 0
        if db ~= nil then
            db:clear()
        end
    end

    ---Checks if all keys are loaded
    ---@return boolean
    function BufferedDB:IsLoaded()
        return loaded
    end

    ---Checks if all data has been persisted
    ---@return boolean
    function BufferedDB:IsDirty()
        return dirtyCount > 0
    end

    ---Gets data from keym or default
    ---@param key string
    ---@param default number|string|table
    ---@return number|string|table
    function BufferedDB:Get(key, default)
        if not loaded then
            error("Call to Get before loading is completed")
        end

        local entry = buffer[key]
        if entry == nil then
            return default
        else
            return entry.value
        end
    end

    ---Puts data in key
    ---@param key string
    ---@param data number|string|table
    function BufferedDB:Put(key, data)
        if not loaded then
            error("Call to Put before loading is completed")
        end

        buffer[key] = DBStoredData.New(data, true)
        dirtyCount = dirtyCount + 1
    end


    return setmetatable(s, BufferedDB)
end

return BufferedDB