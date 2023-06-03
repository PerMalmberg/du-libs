local calc = require("util/Calc")

---@class NumberShape
---@field New fun(core:CoreUnit, number:number, worldPos:Vec3):NumberShape
---@field Draw fun()
---@field Remove fun()

local NumberShape = {}
NumberShape.__index = NumberShape

---@param core CoreUnit
---@param number number
---@param worldPos Vec3
---@return NumberShape
function NumberShape.New(core, number, worldPos)
    local s = {
        index = -1,
        updateHandler = -1
    }

    function s.Draw()
        local constructLocal = calc.WorldToLocal(worldPos)
        if s.index == -1 then
            s.index = core.spawnNumberSticker(number, constructLocal.x, constructLocal.y, constructLocal.z,
                "front")
        else
            core.moveSticker(s.index, constructLocal.x, constructLocal.y, constructLocal.z)
        end
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
