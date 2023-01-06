local Vec3 = require("math/Vec3")

---@alias TelemeterVec3 {x:number, y:number, z:number}
---@alias TelemeterData {hit:boolean, distance:number, point:TelemeterVec3}
---@alias TeleRaycast fun():TelemeterData
---@alias TeleDist fun():number
---@alias TeleWorldAxis fun():TelemeterVec3
---@alias TelementerAPI {raycast:TeleRaycast, getMaxDistance:TeleDist, getRayWorldAxis:TeleWorldAxis, getRayWorldOrigin:TeleWorldAxis}
---@alias TelemeterResult {Hit:boolean, distance:number, point:Vec3}

---@class Telemeter
---@field New fun(telemeter:TelementerAPI):Telemeter
---@field Measure fun():TelemeterResult
---@field IsTelemeter fun():boolean

local Telemeter = {}
Telemeter.__index = Telemeter

---Create a new Telemeter
---@param telemeter TelementerAPI
function Telemeter.New(telemeter)
    local s = {}

    ---Measure distance
    ---@return TelemeterResult
    function s.Measure()
        local res = telemeter.raycast()
        return { Hit = true, Point = Vec3.New(res.point), Distance = res.distance }
    end

    ---Checks if the link has the expected functions
    ---@return boolean
    function s.IsTelemeter()
        return type(telemeter.getMaxDistance) == "function"
            and type(telemeter.raycast) == "function"
            and type(telemeter.getRayWorldOrigin) == "function"
    end

    return setmetatable(s, Telemeter)
end

return Telemeter
