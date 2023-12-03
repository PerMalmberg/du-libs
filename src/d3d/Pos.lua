---@class D3dPos
---@field New fun(x:number, y:number):D3dPos
---@field FromPercent fun(resolution:D3dPos)
---@field x number
---@field y number

local D3dPos = {}
D3dPos.__index = D3dPos

---@param x number
---@param y number
---@return D3dPos
function D3dPos.New(x, y)
    local s = {
        x = x,
        y = y
    }

    ---@param res D3dPos
    ---@return D3dPos
    function s.FromPercent(res)
        s.x = s.x * res.x
        s.y = s.y * res.y
        return s
    end

    return setmetatable(s, D3dPos)
end

return D3dPos
