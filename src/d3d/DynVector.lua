local Line = require("d3d/Line")
local Pos  = require("d3d/Pos")
require("d3d/Common")

local D3dVector   = {}
D3dVector.__index = D3dVector

---@alias VectorFunc fun():Vec3, Vec3

---@param length number
---@param baseAndDir VectorFunc
---@param width number
---@param color string
function D3dVector.New(length, baseAndDir, width, color)
    local s = {}

    local line = Line.New(Pos.New(0, 0), Pos.New(0, 0), width, color)

    ---@param res D3dPos
    ---@return string
    function s.R(res)
        local base, dir = baseAndDir()
        dir = D3dVecToScreen(base + dir * length)
        base = D3dVecToScreen(base)
        line.SetPos(Pos.New(base.x, base.y).FromPercent(res), Pos.New(dir.x, dir.y).FromPercent(res))
        return line.R(res)
    end

    return setmetatable(s, D3dVector)
end

return D3dVector
