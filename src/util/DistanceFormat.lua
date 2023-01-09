local oneSU = 200000
local oneKm = 1000

---@param distance number
---@return {value:number, unit:string}
function DistanceFormat(distance)
    if distance >= oneSU then
        return { value = distance / oneSU, unit = "su" }
    elseif distance >= oneKm then
        return { value = distance / oneKm, unit = "km" }
    else
        return { value = distance, unit = "m" }
    end
end

return DistanceFormat
