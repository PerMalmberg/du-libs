---@class PubSub
---@field RegisterString fun(topic:string, callback:TopicStringCallback)
---@field RegisterNumber fun(topic:string, callback:TopicNumberCallback)
---@field RegisterTable fun(topic:string, callback:TopicTableCallback)
---@field Publish fun(topic:string, value:string)

---@alias TopicStringCallback fun(topic:string, value:string)
---@alias TopicNumberCallback fun(topic:string, value:number)
---@alias TopicBooleanCallback fun(topic:string, value:boolean)
---@alias TopicTableCallback fun(topic:string, value:table)


local PubSub = {}
PubSub.__index = PubSub
local singelton

function PubSub.Instance()
    if singelton then
        return singelton
    end

    local s = {}
    local subscribers = {
        number = {}, ---@type table<string, TopicNumberCallback[]>
        string = {}, ---@type table<string, TopicStringCallback[]>
        table = {}, ---@type table<string, TopicTableCallback[]>
        boolean = {} ---@type table<string, TopicBooleanCallback[]>
    }

    ---@param subs table
    ---@param topic string
    ---@param callback TopicStringCallback|TopicNumberCallback|TopicTableCallback
    local function register(subs, topic, callback)
        local callbacks = subs[topic]
        if not callbacks then
            callbacks = {}
            subs[topic] = callbacks
        end

        table.insert(callbacks, callback)
    end

    ---Registers a string callback for the topic
    ---@param topic string
    ---@param callback TopicStringCallback
    function s.RegisterString(topic, callback)
        register(subscribers[type("")], topic, callback)
    end

    ---Registers a number callback for the topic
    ---@param topic string
    ---@param callback TopicNumberCallback
    function s.RegisterNumber(topic, callback)
        register(subscribers[type(1)], topic, callback)
    end

    ---Registers a table callback for the topic
    ---@param topic string
    ---@param callback TopicTableCallback
    function s.RegisterTable(topic, callback)
        register(subscribers[type({})], topic, callback)
    end

    ---Registers a boolean callback for the topic
    ---@param topic string
    ---@param callback TopicBooleanCallback
    function s.RegisterBool(topic, callback)
        register(subscribers[type(true)], topic, callback)
    end

    ---Publishes the value on the topic
    ---@param topic string
    ---@param value string|number|table|boolean
    function s.Publish(topic, value)
        local t = type(value)
        local subs = subscribers[t]

        if not subs then return end

        local callbacks = subs[topic]
        if callbacks then
            for _, subscriber in ipairs(callbacks) do
                subscriber(topic, value)
            end
        end
    end

    singelton = setmetatable(s, PubSub)
    return singelton
end

return PubSub
