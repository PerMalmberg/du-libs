local Pos = require("d3d/Pos")

---@alias PartRender fun(res:D3dPos):string
---@alias Part {R:PartRender}



return {
    Draw = require("d3d/Draw"),
    Layer = require("d3d/Layer"),
    Pos = Pos,
    Line = require("d3d/Line"),
    DynVector = require("d3d/DynVector")
}
