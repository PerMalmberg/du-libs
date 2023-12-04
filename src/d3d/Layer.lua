---@class D3dLayer
---@field New fun():D3dLayer
---@field G fun(res:D3dPos):string
---@field Clear fun()
---@field Static fun(part:Part)
---@field Single fun(part:Part)

local D3dLayer = {}
D3dLayer.__index = D3dLayer

---@return D3dLayer
function D3dLayer.New()
    local s = {}
    local static = {} ---@type Part[]
    local preStatic = nil ---@type string|nil

    local single = {} ---@type Part[]

    ---@param parts Part[]
    ---@alias res D3dPos Resolution
    ---@return string
    local function assemble(parts, res)
        local all = ""
        for _, p in ipairs(parts) do
            all = all .. p.R(res)
        end

        return all
    end

    ---@param res D3dPos
    ---@return string
    local function getParts(res)
        if preStatic == nil then
            preStatic = assemble(static, res)
        end

        return preStatic .. assemble(single, res)
    end

    ---@param res D3dPos
    ---@return string
    function s.G(res)
        -- Return an SVG that sits on top of everything and covers the entire screen
        local g = string.format(
            [[<g width="%d" height="%d" style="position:absolute; top:0px; left:0px;">%s</g>]], res.x, res.y,
            getParts(res))
        single = {}
        return g
    end

    ---@param part Part
    function s.Static(part)
        static[#static + 1] = part
        preStatic = nil
    end

    ---@param part Part
    function s.Single(part)
        single[#single + 1] = part
    end

    function s.Clear()
        static = {}
        preStatic = ""
        single = {}
    end

    return setmetatable(s, D3dLayer)
end

return D3dLayer
