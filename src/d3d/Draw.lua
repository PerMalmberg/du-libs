local Pos = require("d3d/Pos")

---@class D3dDraw
---@field Instance fun():D3dDraw
---@field Add fun(index:integer, l:D3dLayer)
---@field Render fun():string
---@field RenderToScreen fun()
---@field Show fun(show:boolean)

local D3dDraw = {}
D3dDraw.__index = D3dDraw

local inst

local html = [[<!DOCTYPE html><html><head><style>%s</style></head><body>%s</body></html>]]

local divTpl = "<div>%s</div>"
local svgTpl =
[[<svg width="%d" height="%d" viewbox="0 0 100%% 100%%" style="position:absolute; top:0px; left:0px;">%s</svg>]]

---@return D3dDraw
function D3dDraw.Instance()
    if inst then
        return inst
    end

    local s = {}
    local layer = {} ---@type table<integer, D3dLayer>

    ---@return D3dPos
    local function res()
        return Pos.New(system.getScreenWidth(), system.getScreenHeight())
    end

    ---@param index integer
    ---@param l D3dLayer
    function s.Add(index, l)
        layer[index] = l
    end

    ---Renders all layers as a single SVG
    ---@return string
    function s.Render()
        local r = res()

        local indexes = {}
        for i, _ in pairs(layer) do
            indexes[#indexes + 1] = i
        end

        table.sort(indexes)

        local layers = ""
        for _, l in ipairs(indexes) do
            layers = layers .. layers[l].G(r)
        end

        local svg = string.format(svgTpl, r.x, r.y, layers)

        return svg
    end

    ---Renders all layers to screen, with each layer as a div to make them actually be layered
    function s.RenderToScreen()
        local r = res()

        -- Put each layer in a div to make them layered
        local divs = ""

        for _, l in ipairs(layer) do
            divs = divs .. string.format(divTpl, string.format(svgTpl, r.x, r.y, l.G(r)))
        end

        local globalStyles = "" -- For later
        local svg = string.format(html, globalStyles, divs)
        system.setScreen(svg)
    end

    ---Shows or hides the drawing
    ---@param show boolean
    function s.Show(show)
        system.showScreen(show)
    end

    inst = setmetatable(s, D3dDraw)
    return inst
end

return D3dDraw
