local Number = require("debug/NumberShape")

---@class Visual
---@field New fun():Visual
---@field DrawNumber fun(number:number, coord:Vec3)
---@field RemoveNumber fun(number:number)

local Visual = {}
Visual.__index = Visual

local instance ---@type Visual

function Visual.New()
    if instance then return instance end

    local s = {}
    local numbers = {} ---@type NumberShape[]

    ---Draws a number
    ---@param number number
    ---@param worldPos Vec3
    function s.DrawNumber(number, worldPos)
        local shape = numbers[number]
        if shape ~= nil then
            shape.SetPos(worldPos)
        else
            numbers[number] = Number.New(library.getCoreUnit(), number, worldPos)
        end
    end

    function s.RemoveNumber(number)
        local shape = numbers[number]
        if shape then
            shape.Remove()
            numbers[number] = nil
        end
    end

    return setmetatable(s, Visual)
end

return Visual
