local typeComp = require("debug/TypeComp")

local check = {}

local function formatTypeMessage(parameterName, parameter, wantedTypeName, functionName)
    return string.format("'%s' in '%s' must be '%s', got '%s'", parameterName, functionName, wantedTypeName,
        type(parameter))
end

function check.IsString(s, parameterName, functionName)
    assert(typeComp.IsString(s), formatTypeMessage(parameterName, s, "string", functionName))
end

function check.IsTable(t, parameterName, functionName)
    assert(typeComp.IsTable(t), formatTypeMessage(parameterName, t, "table", functionName))
end

function check.IsVec3(v, parameterName, functionName)
    assert(typeComp.IsTable(v) and typeComp.IsNumber(v.x and v.y and v.z) and typeComp.IsFunction(v.ProjectOn),
        formatTypeMessage(parameterName, v, "vec3", functionName))
end

function check.IsNumber(n, parameterName, functionName)
    assert(typeComp.IsNumber(n), formatTypeMessage(parameterName, n, "number", functionName))
end

function check.IsBoolean(n, parameterName, functionName)
    assert(typeComp.IsBoolean(n), formatTypeMessage(parameterName, n, "boolean", functionName))
end

function check.IsFunction(f, parameterName, functionName)
    assert(typeComp.IsFunction(f), formatTypeMessage(parameterName, f, "function", functionName))
end

function check.IsRay(r, parameterName, functionName)
    assert(typeComp.IsRay(r), formatTypeMessage(parameterName, r, "Ray", functionName))
end

function check.Equals(a, b)
    assert(a == b)
end

function check.Fail(msg)
    assert(false, msg)
end

return check
