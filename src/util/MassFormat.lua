local oneTon = 1000
local kiloTon = 1000 * 1000

---@param kg number
function MassFormat(kg)
    if kg >= kiloTon then
        return { value = kg / kiloTon, unit = "kt" }
    elseif kg >= oneTon then
        return { value = kg / oneTon, unit = "t" }
    else
        return { value = kg, unit = "kg" }
    end
end

return MassFormat
