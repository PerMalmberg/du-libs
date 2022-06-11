local Number = require("debug/NumberShape")
local library = require("abstraction/Library")()

local visual = {}
visual.__index = visual

local function new()
    o = {
        shapes = {}
    }
    return setmetatable(o, visual)
end

---Draws a number
---@param number number
---@param worldPos vec3
function visual:DrawNumber(number, worldPos)
    local s = self.shapes[number]
    if s ~= nil then
        s.worldPos = worldPos
    else
        self.shapes[number] = Number(library:GetCoreUnit(), number, worldPos)
    end
end

function visual:RemoveNumber(number)
    local s = self.shapes[number]
    if s then
        s:Remove()
        self.shapes[number] = nil
    end
end

local singleton = nil

return setmetatable(
        {
            new = new
        },
        {
            __call = function(_, ...)
                if singleton == nil then
                    singleton = new()
                end

                return singleton
            end
        }
)