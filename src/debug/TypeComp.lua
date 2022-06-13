local typeComp = {}
typeComp.__index = typeComp

function typeComp.IsNumber(n)
    return type(n) == "number"
end

function typeComp.IsTable(t)
    return type(t) == "table"
end

function typeComp.IsString(s)
    return type(s) == "string"
end

function typeComp.IsFunction(f)
    return type(f) == "function"
end

function typeComp.IsBoolean(b)
    return type(b) == "boolean"
end

function typeComp.IsVec3(v)
    return typeComp.IsTable(v) and typeComp.IsNumber(v.x and v.y and v.z) and typeComp.IsFunction(v.trim_inplace)
end

return typeComp