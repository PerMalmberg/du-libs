---@class PubSub
---@field Register fun(topic:string, callback:TopicCallback)
---@field Publish fun(topic:string, value:string)

---@alias TopicCallback fun(topic:string, value:string)

local PubSub = {}
PubSub.__index = PubSub
local singelton

function PubSub.Instance()
    if singelton then
        return singelton
    end

    local s = {}
    local subscribers = {} ---@type table<string, TopicCallback[]>

    ---Registers a callback for the topic
    ---@param topic string
    ---@param callback TopicCallback
    function s.Register(topic, callback)
        local callbacks = subscribers[topic]
        if not callbacks then
            callbacks = {}
            subscribers[topic] = callbacks
        end

        table.insert(callbacks, callback)
    end

    ---Publishes the value on the topic
    ---@param topic string
    ---@param value string
    function s.Publish(topic, value)
        local callbacks = subscribers[topic]
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
