---@class PubSub
---@field RegisterString fun(topic:string, callback:SubStringCallback)
---@field RegisterNumber fun(topic:string, callback:SubNumberCallback)
---@field RegisterTable fun(topic:string, callback:SubTableCallback)
---@field RegisterBool fun(topic:string, callback:SubBooleanCallback)
---@field Publish fun(topic:string, value:string|number|table|boolean, yield:boolean?)
---@field Unregister fun(topic:string, callback:SubStringCallback|SubNumberCallback|SubTableCallback|SubBooleanCallback)
---@field Instance fun():PubSub

---@alias SubStringCallback fun(topic:string, value:string)
---@alias SubNumberCallback fun(topic:string, value:number)
---@alias SubBooleanCallback fun(topic:string, value:boolean)
---@alias SubTableCallback fun(topic:string, value:table)


local PubSub = {}
PubSub.__index = PubSub
local singelton

---Gets the instance
---@return PubSub
function PubSub.Instance()
    if singelton then
        return singelton
    end

    local s = {}
    local subscribers = {
        number = {}, ---@type table<string, SubNumberCallback[]>
        string = {}, ---@type table<string, SubStringCallback[]>
        table = {}, ---@type table<string, SubTableCallback[]>
        boolean = {} ---@type table<string, SubBooleanCallback[]>
    }

    ---@param subs table
    ---@param topic string
    ---@param callback SubStringCallback|SubNumberCallback|SubTableCallback|SubBooleanCallback
    local function register(subs, topic, callback)
        local callbacks = subs[topic]
        if not callbacks then
            callbacks = {}
            subs[topic] = callbacks
        end

        table.insert(callbacks, callback)
    end

    ---@param topic string
    ---@param callback SubStringCallback|SubNumberCallback|SubTableCallback|SubBooleanCallback
    function s.Unregister(topic, callback)
        for _, topics in pairs(subscribers) do
            local subs = topics[topic]
            if subs then
                for index, sub in ipairs(subs) do
                    if sub == callback then
                        table.remove(subs, index)
                        return
                    end
                end
            end
        end
    end

    ---Registers a string callback for the topic
    ---@param topic string
    ---@param callback SubStringCallback
    function s.RegisterString(topic, callback)
        register(subscribers[type("")], topic, callback)
    end

    ---Registers a number callback for the topic
    ---@param topic string
    ---@param callback SubNumberCallback
    function s.RegisterNumber(topic, callback)
        register(subscribers[type(1)], topic, callback)
    end

    ---Registers a table callback for the topic
    ---@param topic string
    ---@param callback SubTableCallback
    function s.RegisterTable(topic, callback)
        register(subscribers[type({})], topic, callback)
    end

    ---Registers a boolean callback for the topic
    ---@param topic string
    ---@param callback SubBooleanCallback
    function s.RegisterBool(topic, callback)
        register(subscribers[type(true)], topic, callback)
    end

    ---Publishes the value on the topic
    ---@param topic string
    ---@param value string|number|table|boolean
    ---@param yield boolean? Set to true to yield between each callback; only when run in a coroutine.
    function s.Publish(topic, value, yield)
        local subs = subscribers[type(value)]

        if not subs then return end

        local callbacks = subs[topic]
        if not callbacks then return end

        for _, subscriber in ipairs(callbacks) do
            subscriber(topic, value)
            if yield then coroutine.yield() end
        end
    end

    singelton = setmetatable(s, PubSub)
    return singelton
end

return PubSub
