local Task = require("system/Task")
local log = require("debug/Log").Instance()
require("util/Table")
local DBStoredData = require("storage/DBStoredData")

---@class BufferedDB
---@field BeginLoad fun() Starts loading keys into memory
---@field Clear fun() Clears the databank
---@field IsLoaded fun():boolean Returns true when all keys have been loaded.
---@field IsDirty fun():boolean Returns true when a key has not yet been persisted
---@field Get fun(key:string, default:any):number|string|boolean|table|nil Returns the value of the key, or the default value
---@field Number fun(key:string, default:number):number Returns the value, or default
---@field Bool fun(key:string, default:boolean):boolean Returns the value, or default
---@field Put fun(key:string, data:number|string|boolean|table) Stores the data in key. data can be string, number or (plain data) table.
---@field Size fun():number Returns the number of keys

local BufferedDB = {}
BufferedDB.__index = BufferedDB

---Creates a new BufferedDB
---@param databank table|nil The link to the the databank element we're expecting to be connected to.
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
    local task

    local function persist()
        loaded = true
        while true do
            if s.IsDirty() then
                for key, data in pairs(buffer) do
                    coroutine.yield()

                    if data.dirty then
                        db.setStringValue(key, data.Persist())
                        dirtyCount = dirtyCount - 1
                    end
                end
            end
            coroutine.yield()
        end
    end

    ---Begins loading keys
    function s.BeginLoad()
        if task then
            return
        end

        task = Task.New("BufferedDB", function()
            local keys = db.getKeyList()
            for i, k in ipairs(keys) do
                local d = DBStoredData.NewFromDB(db.getStringValue(k))

                if d then
                    buffer[k] = d
                else
                    log.Error("Could not load key '", k, "'")
                end

                coroutine.yield()
            end
        end).Then(persist).Catch(function(t)
            error("Error in BeginLoad:" .. t.Error())
        end)
    end

    function s.Clear()
        if not loaded then
            error("Call to Clear before loading is completed")
        end

        buffer = {}
        dirtyCount = 0
        db.clear()
    end

    ---Checks if all keys are loaded
    ---@return boolean
    function s.IsLoaded()
        return loaded
    end

    ---Checks if all data has been persisted
    ---@return boolean
    function s.IsDirty()
        return dirtyCount > 0
    end

    ---Gets data from key or default
    ---@param key string
    ---@param default number|string|boolean|table
    ---@return number|string|boolean|table|nil
    function s.Get(key, default)
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

    ---@param key string
    ---@param default number
    function s.Number(key, default)
        return s.Get(key, default)
    end

    ---@param key string
    ---@param default boolean
    function s.Boolean(key, default)
        return s.Get(key, default)
    end

    ---Puts data in key
    ---@param key string
    ---@param data number|string|boolean|table|boolean
    function s.Put(key, data)
        if not loaded then
            error("Call to Put before loading is completed")
        end

        buffer[key] = DBStoredData.New(data, true)
        dirtyCount = dirtyCount + 1
    end

    function s.Size()
        return TableLen(buffer)
    end

    return setmetatable(s, BufferedDB)
end

return BufferedDB
