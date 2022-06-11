local json = require("dkjson")
local library = require("abstraction/Library")
local CoRunner = require("system/CoRunner")
local checks = require("debug/Checks")

local storage = {}
storage.__index = storage

local function new(storageName)

    local o = {
        name = storageName,
        buffer = {},
        db = nil,
        coRunner = CoRunner(1)
    }

    setmetatable(o, storage)

    return o
end

function storage:Init()
    self.db = library:GetLinkByName(self.name)
    if self.db == nil then
        checks.AssertIsTable(db, "self.name", "storage:Init")
    end

    self:load()
end

function storage:load()
    local keys = self.db.getKeys()
    keys = json.decode(keys)
    for _, k in ipairs(keys) do
        self.buffer[k] = self.db.getStringValue(k)
    end
end

function storage:Clear()
    self.buffer = {}
    self.db.Clear()
end

function storage:Flush()
    for _, key in self.buffer do
        if self.buffer[key]["dirty"] then
            local v = self.buffer[key]["value"]
            local t = type(v)
            if t == "number" or t == "string" then
                self.db.setStringValue(key, tostring(v))
            elseif t == "table" then
                local s = json.encode(v)
                self.db.setStringValue(key, s)
            end
            self.buffer[key]["dirty"] = false
        end
    end
end

function storage:ReadNumber(key)
    return tonumber(self.db.getStringValue(key))
end

function storage:ReadString(key)
    return db.getStringValue(key)
end

function storage:ReadObject(key)
    local s = self.db.getStringValue(key)
    return json.decode(s)
end

function storage:ReadObject(key, data)

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