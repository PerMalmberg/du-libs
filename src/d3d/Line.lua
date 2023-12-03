---@class D3dLine
---@field New fun(a:D3dPos, b:D3dPos, width:number, color:string):D3dLine
---@field R fun(resolution:D3dPos):string
---@field SetPos fun(a:D3dPos|nil, b:D3dPos|nil)

local D3dLine = {}
D3dLine.__index = D3dLine

---@param a D3dPos
---@param b D3dPos
---@param width number
---@param color string
---@return D3dLine
function D3dLine.New(a, b, width, color)
    local s = {
        p1 = a,
        p2 = b
    }

    ---@param res D3dPos Resolution
    function s.R(res)
        return string.format([[<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="%s" stroke-width="%f"/>]],
            s.p1.x, s.p1.y, s.p2.x, s.p2.y, color, width)
    end

    ---@param p1 D3dPos
    ---@param p2 D3dPos
    function s.SetPos(p1, p2)
        if p1 then
            s.p1 = p1
        end

        if p2 then
            s.p2 = p2
        end
    end

    return setmetatable(s, D3dLine)
end

return D3dLine
