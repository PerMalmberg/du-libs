local json = require("dkjson")
local library = require("abstraction/Library")()
local CoRunner = require("system/CoRunner")
local log = require("debug/Log")()
require("util/Table")

---@class BufferedDB
---@field BeginLoad fun() Starts loading keys into memory
---@field Clear fun() Clears the databank
---@field IsLoaded fun():boolean Returns true when all keys have been loaded.
---@field IsDirty fun():boolean Returns true when a key has not yet been persisted
---@field Get fun(key:string, default):number|string|table Returns the value of the key, or the default value
---@field Put fun(key:string, data:number|string|table) Stores the data in key. data can be string, number or (plain data) table.

local BufferedDB = {}
BufferedDB.__index = BufferedDB

---Creates a new BufferedDB
---@param storageName string The name of the databank element we're expecting to be connected to. 
---@return BufferedDB
function BufferedDB.New(storageName)

    local s = {}

    local name = storageName
    local buffer = {} ---@type {[string]:number|string|table}
    local db = library:GetLinkByName(storageName)
    local loaded = false
    local dirtyCount = 0
    local coRunner ---@type CoRunner

    if o.db == nil then
        log:Error("No linked databank with name '", storageName, "' found")
        unit.exit()
    end

    setmetatable(o, BufferedDB)

    ---Begins loading keys
    function BufferedDB:BeginLoad()
        if db == nil then
            return false
        end

        coRunner = CoRunner(0.1)
        s:load()
    end

    function BufferedDB:load()
        coRunner:Execute(
                function()
                    local keys = db.getKeyList()
                    log:Debug("Loading from DB", name)
                    for i, k in ipairs(keys) do
                        local data = json.decode(db.getStringValue(k))
                        -- We always expect a table here, if we don't get that, then the data isn't written by this class
                        if data ~= nil and type(data) == "table" and data.t and data.d then
                            local o = { dirty = false }

                            if data.t == "number" then
                                o.value = tonumber(data.d)
                            elseif data.t == "string" then
                                o.value = data.d
                            else
                                -- table
                                o.value = data.d
                            end

                            buffer[k] = o
                        end
                        -- Load X keys at a time
                        if i % 10 == 0 then
                            coroutine.yield()
                        end
                    end
                end,
                function()
                    log:Info(TableLen(buffer) .. " keys loaded from data bank '", name, "'")
                    loaded = true
                    coRunner:Execute(function()
                        self:persist()
                    end)
                end)
    end

    function BufferedDB:Clear()
        buffer = {}
        dirtyCount = 0
        if db ~= nil then
            db:clear()
        end
    end

    function BufferedDB:persist()
        while true do
            coroutine.yield()
            if self:IsDirty() then
                local i = 0
                for key, data in pairs(buffer) do
                    if i % 5 == 0 then
                        coroutine.yield()
                    end

                    if data.dirty then
                        local v = data.value
                        local s = json.encode({ t = type(v), d = v })
                        db.setStringValue(key, s)
                        buffer[key].dirty = false
                        dirtyCount = dirtyCount - 1
                    end
                    i = i + 1
                end
            end
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
        buffer[key] = {
            dirty = true,
            value = data
        }
        dirtyCount = dirtyCount + 1
    end


    return setmetatable(s, BufferedDB)
end

return BufferedDB