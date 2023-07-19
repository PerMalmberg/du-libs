local calc = require("util/Calc")
local Vec3 = require("math/Vec3")

---@class NumberShape
---@field New fun(core:CoreUnit, number:number, worldPos:Vec3):NumberShape
---@field Draw fun()
---@field Remove fun()
---@field SetPos fun(worldPos:Vec3)

local NumberShape = {}
NumberShape.__index = NumberShape

---@param core CoreUnit
---@param number number
---@param worldPos Vec3
---@return NumberShape
function NumberShape.New(core, number, worldPos)
    local s = {
        index = -1,
        updateHandler = -1,
        worldPos = worldPos
    }

    function s.Draw()
        local constructLocal = calc.WorldToLocal(s.worldPos)
        if s.index == -1 then
            s.index = core.spawnNumberSticker(number, constructLocal.x, constructLocal.y, constructLocal.z,
                "front")
        else
            system.print("moved: " .. tostring(s.index) .. " " .. tostring(
                core.moveSticker(s.index, constructLocal.x, constructLocal.y, constructLocal.z)))
        end
    end

    ---@param worldPos Vec3
    function s.SetPos(newWorldPos)
        s.worldPos = newWorldPos
    end

    function s.Remove()
        if s.index ~= -1 then
            system:clearEvent("update", s.updateHandler)
            core.deleteSticker(s.index)
            s.index = -1
        end
    end

    s.updateHandler = system:onEvent("onUpdate", s.Draw, s)
    return setmetatable(s, NumberShape)
end

return NumberShape
