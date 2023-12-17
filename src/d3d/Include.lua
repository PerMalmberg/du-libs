---@module "d3d.Pos"
---@module "d3d.Draw"
---@module "d3d.Layer"

local Pos = require("d3d/Pos")

---@alias PartRender fun(res:D3dPos):string
---@alias Part {R:PartRender}

require("d3d/Common")

return {
    Draw = require("d3d/Draw"),
    Layer = require("d3d/Layer"),
    Pos = Pos,
    Line = require("d3d/Line"),
    DynVector = require("d3d/DynVector")
}
