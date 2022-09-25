local CoRunner = require("system/CoRunner")
local log = require("debug/Log")()
require("util/Table")
local DBStoredData = require("storage/DBStoredData")

---@class BufferedDB
---@field BeginLoad fun(_:table) Starts loading keys into memory
---@field Clear fun(_:table) Clears the databank
---@field IsLoaded fun(_:table):boolean Returns true when all keys have been loaded.
---@field IsDirty fun(_:table):boolean Returns true when a key has not yet been persisted
---@field Get fun(_:table, key:string, default):number|string|table|nil Returns the value of the key, or the default value
---@field Put fun(_:table, key:string, data:number|string|table) Stores the data in key. data can be string, number or (plain data) table.
---@field Size fun():number Returns the number of keys

local BufferedDB = {}
BufferedDB.__index = BufferedDB

---Creates a new BufferedDB
---@param databank table The link to the the databank element we're expecting to be connected to.
---@return BufferedDB
function BufferedDB.New(databank)
    if type(databank) ~= "table" or not databank.getStringValue then
        error("databank parameter of BufferedDB.New must be a link to a databank")
    end

    local s = {}

    local buffer = {} ---@type {[string]:DBStoredData}
    local db = databank
    local loaded = false
    local dirtyCount = 0
    local coRunner = CoRunner.New(0.1)

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
                        db.setStringValue(key, data:Persist())
                        dirtyCount = dirtyCount - 1
                    end
                    i = i + 1
                end
            end
        end
    end

    ---Begins loading keys
    function BufferedDB:BeginLoad()
        coRunner:Execute(
            function()
                local keys = db.getKeyList()
                for i, k in ipairs(keys) do
                    local d = DBStoredData.NewFromDB(db.getStringValue(k))

                    if d then
                        buffer[k] = d
                    else
                        log:Error("Could not load key '", k, "'")
                    end

                    -- Load X keys at a time
                    if i % 10 == 0 then
                        coroutine.yield()
                    end
                end
            end,
            function()
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
        db.clear()
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

    ---Gets data from key or default
    ---@param key string
    ---@param default number|string|table
    ---@return number|string|table|nil
    function BufferedDB:Get(key, default)
        if not loaded then
            error("Call to Get before loading is completed")
        end

        local entry = buffer[key]
        if entry then
            return entry.value
        else
            return default
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

    function BufferedDB:Size()
        return TableLen(buffer)
    end

    return setmetatable(s, BufferedDB)
end

return BufferedDB
