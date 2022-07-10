local json = require("dkjson")
local library = require("abstraction/Library")()
local CoRunner = require("system/CoRunner")
local log = require("debug/Log")()

local storage = {}
storage.__index = storage

local function new(storageName)

    local o = {
        name = storageName,
        buffer = {},
        db = library:GetLinkByName(storageName),
        loaded = false,
        dirtyCount = 0
    }

    if o.db == nil then
        log:Error("No linked databank with name '", storageName, "' found")
        unit.exit()
    end

    setmetatable(o, storage)

    return o
end

function storage:BeginLoad()
    if self.db == nil then
        return false
    end

    self.coRunner = CoRunner(0.1)
    self:load()
end

function storage:load()
    self.coRunner:Execute(
            function()
                local keys = self.db.getKeyList()
                keys = json.decode(keys)
                log:Debug("Loading from DB", self.name)
                for i, k in ipairs(keys) do
                    local data = json.decode(self.db.getStringValue(k))
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

                        self.buffer[k] = o
                    end
                    -- Load X keys at a time
                    if i % 10 == 0 then
                        coroutine.yield()
                    end
                end
            end,
            function()
                log:Info(#self.buffer .. " keys loaded from", self.name)
                self.loaded = true
                self.coRunner:Execute(function()
                    self:persist()
                end)
            end)
end

function storage:Clear()
    self.buffer = {}
    self.dirtyCount = 0
    if self.db ~= nil then
        self.db:clear()
    end
end

function storage:persist()
    while true do
        coroutine.yield()
        if self:IsDirty() then
            local i = 0
            for key, data in pairs(self.buffer) do
                if i % 5 == 0 then
                    coroutine.yield()
                end

                if data.dirty then
                    local v = data.value
                    local s = json.encode({ t = type(v), d = v })
                    self.db.setStringValue(key, s)
                    self.buffer[key].dirty = false
                    self.dirtyCount = self.dirtyCount - 1
                end
                i = i + 1
            end
        end
    end
end

function storage:IsLoaded()
    return self.loaded
end

function storage:IsDirty()
    return self.dirtyCount > 0
end

function storage:Get(key, default)
    local entry = self.buffer[key]
    if entry == nil then
        return default
    else
        return entry.value
    end
end

function storage:Put(key, data)
    self.buffer[key] = {
        dirty = true,
        value = data
    }
    self.dirtyCount = self.dirtyCount + 1
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