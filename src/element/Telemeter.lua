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
---@param api TelementerAPI
---@return Telemeter
function Telemeter.New(api)
    local s = {}

    ---Measure distance
    ---@return TelemeterResult
    function s.Measure()
        local res = api.raycast()
        return { Hit = true, Point = Vec3.New(res.point), Distance = res.distance }
    end

    ---Checks if the link has the expected functions
    ---@return boolean
    function s.IsTelemeter()
        return type(api.getMaxDistance) == "function"
            and type(api.raycast) == "function"
            and type(api.getRayWorldOrigin) == "function"
    end

    return setmetatable(s, Telemeter)
end

return Telemeter
