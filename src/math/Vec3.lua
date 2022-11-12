--- A 3 component vector.
-- https://github.com/excessive/cpml/blob/master/modules/Vec3.lua

local sqrt = math.sqrt
local cos  = math.cos
local sin  = math.sin
local acos = math.acos

---@class Vec3
---@field x number
---@field y number
---@field z number
---@field New fun(a:number, b:number, c:number):Vec3
---@field unit_x Vec3 X axis of rotation
---@field unit_y Vec3 Y axis of rotation
---@field unit_z Vec3 Z axis of rotation
---@field zero Vec3 Empty vector
---@field Clone fun():Vec3
---@field Add fun(a:Vec3, b:Vec3):Vec3
---@field Sub fun(a:Vec3, b:Vec3):Vec3
---@field Mul fun(a:Vec3, b:Vec3):Vec3
---@field Div fun(a:Vec3, b:Vec3):Vec3
---@field Normalize fun(a:Vec3):Vec3
---@field NormalizeInPlace fun(a:Vec3):Vec3
---@field NormalizeLen fun(a:Vec3):Vec3,number
---@field Trim fun(a:Vec3, len:number):Vec3
---@field TrimInPlace fun(a:Vec3, len:number):Vec3
---@field Cross fun(a:Vec3, b:Vec3):Vec3
---@field Dot fun(a:Vec3, b:Vec3):number
---@field Len fun(a:Vec3):number
---@field Len2 fun(a:Vec3):number
---@field Dist fun(a:Vec3, b:Vec3):number
---@field Dist2 fun(a:Vec3, b:Vec3):number
---@field Scale fun(a:Vec3, b:number):Vec3
---@field ScaleInPlace fun(a:Vec3, b:number):Vec3
---@field Rotate fun(a:Vec3, phi:number, axis:Vec3):Vec3
---@field Perpendicular fun(a:Vec3):Vec3
---@field Lerp fun(a:Vec3, b:Vec3, s:number):Vec3
---@field Unpack fun(a:Vec3):number,number,number
---@field ComponentMin fun(a:Vec3, b:Vec3):Vec3
---@field ComponentMax fun(a:Vec3, b:Vec3):Vec3
---@field FlipX fun(a:Vec3):Vec3
---@field FlipY fun(a:Vec3):Vec3
---@field FlipZ fun(a:Vec3):Vec3
---@field AngleTo fun(a:Vec3, b:Vec3):number
---@field ProjectOn fun(a:Vec3, b:Vec3):Vec3
---@field ProjectOnPlane fun(a:Vec3, planeNormal:Vec3):Vec3
---@field IsVec3 fun(a:any):boolean
---@field IsZero fun(a:Vec3):boolean
---@field ToString fun(a:Vec3):string
---@operator add(Vec3):Vec3
---@operator sub(Vec3):Vec3
---@operator div(Vec3):Vec3
---@operator div(number):Vec3
---@operator mul(Vec3):Vec3
---@operator mul(number):Vec3
---@operator unm:Vec3

local Vec3   = {}
Vec3.__index = Vec3


---Creates a new Vec3
-- X can be {x, y, z} or {x=x, y=y, z=z} or a scalar to fill the vector eg. {x, x, x}
---@param x? number|{x:number,y:number,z:number}|number X component
---@param y? number Y component
---@param z? number Z component
---@return Vec3 out
function Vec3.New(x, y, z)
    local s = {}
    -- number, number, number
    if x and y and z then
        s.x = x
        s.y = y
        s.z = z
        -- {x, y, z} or {x=x, y=y, z=z}
    elseif type(x) == "table" then -- table in vanilla lua, cdata in luajit
        s.x, s.y, s.z = x.x or x[1], x.y or x[2], x.z or x[3]
        -- number
    elseif type(x) == "number" then
        s.x = x
        s.y = x
        s.z = x
    else
        s.x = 0
        s.y = 0
        s.z = 0
    end

    return setmetatable(s, Vec3)
end

--- Constants
Vec3.unit_x = Vec3.New(1, 0, 0)
Vec3.unit_y = Vec3.New(0, 1, 0)
Vec3.unit_z = Vec3.New(0, 0, 1)
Vec3.zero   = Vec3.New(0, 0, 0)

--- Clone a vector.
---@param a Vec3 Vector to be cloned
---@return Vec3
function Vec3.Clone(a)
    return Vec3.New(a.x, a.y, a.z)
end

--- Add two vectors.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return Vec3 out
function Vec3.Add(a, b)
    return Vec3.New(
        a.x + b.x,
        a.y + b.y,
        a.z + b.z
    )
end

--- Subtract one vector from another.
-- Order: If a and b are positions, computes the direction and distance from b to a.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return Vec3 out
function Vec3.Sub(a, b)
    return Vec3.New(
        a.x - b.x,
        a.y - b.y,
        a.z - b.z
    )
end

--- Multiply a vector by another vector.
-- Component-wise multiplication not matrix multiplication.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return Vec3 out
function Vec3.Mul(a, b)
    return Vec3.New(
        a.x * b.x,
        a.y * b.y,
        a.z * b.z
    )
end

--- Divide a vector by another.
-- Component-wise inv multiplication. Like a non-uniform Scale().
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return Vec3 out
function Vec3.Div(a, b)
    return Vec3.New(
        a.x / b.x,
        a.y / b.y,
        a.z / b.z
    )
end

--- Scale a vector to unit length (1).
---@param a Vec3 vector to Normalize
---@return Vec3
function Vec3.Normalize(a)
    if a:IsZero() then
        return Vec3.New()
    end
    return a:Scale(1 / a:Len())
end

---Normalizes the vector in place
---@param a Vec3
---@return Vec3
function Vec3.NormalizeInPlace(a)
    if a:IsZero() then
        return a
    end

    return a:ScaleInPlace(1 / a:Len())
end

--- Scale a vector to unit length (1), and return the input length.
---@param a Vec3 vector to normalize
---@return Vec3, number
function Vec3.NormalizeLen(a)
    if a:IsZero() then
        return Vec3.New(), 0
    end
    local len = a:Len()
    return a:Scale(1 / len), len
end

--- Trim a vector to a given length
---@param a Vec3 vector to be trimmed
---@param len number Length to trim the vector to
---@return Vec3 out
function Vec3.Trim(a, len)
    return a:Normalize():Scale(math.min(a:Len(), len))
end

--- Trim the vector, in place, to a given length
---@param a Vec3 vector to be trimmed
---@param len number Length to trim the vector to
---@return Vec3 out
function Vec3.TrimInPlace(a, len)
    return a:NormalizeInPlace():ScaleInPlace(math.min(a:Len(), len))
end

---Get the cross product of two vectors.
---Resulting direction is right-hand rule normal of plane defined by a and b.
---Magnitude is the area spanned by the parallelograms that a and b span.
---Order: Direction determined by right-hand rule.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return Vec3
function Vec3.Cross(a, b)
    return Vec3.New(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
end

--- Get the dot product of two vectors.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return number
function Vec3.Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

--- Get the length of a vector.
---@param a Vec3 Vector to get the length of
---@return number len
function Vec3.Len(a)
    return sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

--- Get the squared length of a vector.
---@param a Vec3 Vector to get the squared length of
---@return number len
function Vec3.Len2(a)
    return a.x * a.x + a.y * a.y + a.z * a.z
end

--- Get the distance between two vectors.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return number dist
function Vec3.Dist(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return sqrt(dx * dx + dy * dy + dz * dz)
end

--- Get the squared distance between two vectors.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return number dist
function Vec3.Dist2(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return dx * dx + dy * dy + dz * dz
end

--- Scale a vector by a scalar.
---@param a Vec3 Left hand operand
---@param b number Right hand operand
---@return Vec3
function Vec3.Scale(a, b)
    return Vec3.New(a):ScaleInPlace(b)
end

--- Scale a vector, in place, by a scalar.
---@param a Vec3 Left hand operand
---@param b number Right hand operand
---@return Vec3
function Vec3.ScaleInPlace(a, b)
    a.x = a.x * b
    a.y = a.y * b
    a.z = a.z * b
    return a
end

--- Rotate vector about an axis.
---@param a Vec3 Vector to rotate
---@param phi number Angle to rotate vector by (in radians)
---@param axis Vec3 Axis to rotate by
---@return Vec3
function Vec3.Rotate(a, phi, axis)
    if not Vec3.IsVec3(axis) then
        return a
    end

    local u = axis:Normalize()
    local c = cos(phi)
    local s = sin(phi)

    -- Calculate generalized rotation matrix
    local m1 = Vec3.New((c + u.x * u.x * (1 - c)), (u.x * u.y * (1 - c) - u.z * s), (u.x * u.z * (1 - c) + u.y * s))
    local m2 = Vec3.New((u.y * u.x * (1 - c) + u.z * s), (c + u.y * u.y * (1 - c)), (u.y * u.z * (1 - c) - u.x * s))
    local m3 = Vec3.New((u.z * u.x * (1 - c) - u.y * s), (u.z * u.y * (1 - c) + u.x * s), (c + u.z * u.z * (1 - c)))

    return Vec3.New(
        a:Dot(m1),
        a:Dot(m2),
        a:Dot(m3)
    )
end

--- Get the perpendicular vector of a vector.
---@param a Vec3 Vector to get perpendicular axes from
---@return Vec3 out
function Vec3.Perpendicular(a)
    return Vec3.New(-a.y, a.x, 0)
end

--- Lerp between two vectors.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@param s number Step value
---@return Vec3 out
function Vec3.Lerp(a, b, s)
    return a + (b - a) * s
end

--- Unpack a vector into individual components.
---@param a Vec3 Vector to unpack
---@return number x
---@return number y
---@return number z
function Vec3.Unpack(a)
    return a.x, a.y, a.z
end

--- Return the component-wise minimum of two vectors.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return Vec3 A vector where each component is the lesser value for that component between the two given vectors.
function Vec3.ComponentMin(a, b)
    return Vec3.New(math.min(a.x, b.x), math.min(a.y, b.y), math.min(a.z, b.z))
end

--- Return the component-wise maximum of two vectors.
---@param a Vec3 Left hand operand
---@param b Vec3 Right hand operand
---@return Vec3 A vector where each component is the lesser value for that component between the two given vectors.
function Vec3.ComponentMax(a, b)
    return Vec3.New(math.max(a.x, b.x), math.max(a.y, b.y), math.max(a.z, b.z))
end

-- Negate x axis only of vector.
---@param a Vec3 Vector to x-flip.
---@return Vec3
function Vec3.FlipX(a)
    return Vec3.New(-a.x, a.y, a.z)
end

-- Negate y axis only of vector.
---@param a Vec3 Vector to y-flip.
---@return Vec3
function Vec3.FlipY(a)
    return Vec3.New(a.x, -a.y, a.z)
end

-- Negate z axis only of vector.
---@param a Vec3 Vector to z-flip.
---@return Vec3 z-flipped vector
function Vec3.FlipZ(a)
    return Vec3.New(a.x, a.y, -a.z)
end

---Gets the angle to b from a
---@param a Vec3
---@param b Vec3
---@return number
function Vec3.AngleTo(a, b)
    local v = a:Normalize():Dot(b:Normalize())
    return acos(v)
end

---Projects vector a onto b
---@param a Vec3
---@param v Vec3
---@return Vec3
function Vec3.ProjectOn(a, v)
    -- (self * v) * v / v:Len2()
    local s = (a.x * v.x + a.y * v.y + a.z * v.z) / (v.x * v.x + v.y * v.y + v.z * v.z)
    return Vec3.New(s * v.x, s * v.y, s * v.z)
end

---Project a on plane containing origin
---@param a Vec3
---@param planeNormal Vec3
---@return Vec3
function Vec3.ProjectOnPlane(a, planeNormal)
    return a - planeNormal * a:Dot(planeNormal)
end

--- Return a boolean showing if a table is or is not a Vec3.
---@param a any Vector to be tested
---@return boolean is_vec3
function Vec3.IsVec3(a)
    return type(a) == "table" and
        type(a.x) == "number" and
        type(a.y) == "number" and
        type(a.z) == "number"
end

--- Return a boolean showing if a table is or is not a zero Vec3.
---@param a Vec3 Vector to be tested
---@return boolean IsZero
function Vec3.IsZero(a)
    return a.x == 0 and a.y == 0 and a.z == 0
end

--- Return a formatted string.
---@param a Vec3 Vector to be turned into a string
---@return string formatted
function Vec3.ToString(a)
    return string.format("(%+0.3f,%+0.3f,%+0.3f)", a.x, a.y, a.z)
end

function Vec3.__tostring(a)
    return a:ToString()
end

---Negation operator
---@param a Vec3
---@return Vec3
function Vec3.__unm(a)
    return Vec3.New(-a.x, -a.y, -a.z)
end

---Equality operator
---@param a Vec3
---@param b Vec3
---@return boolean
function Vec3.__eq(a, b)
    if not Vec3.IsVec3(a) or not Vec3.IsVec3(b) then
        return false
    end
    return a.x == b.x and a.y == b.y and a.z == b.z
end

---Addition operator
---@param a Vec3
---@param b Vec3
---@return unknown
function Vec3.__add(a, b)
    return a:Add(b)
end

---Subtraction operator
---@param a Vec3
---@param b Vec3
---@return Vec3
function Vec3.__sub(a, b)
    return a:Sub(b)
end

---Multiplication operator
---@param a Vec3|number
---@param b Vec3|number
---@return Vec3
function Vec3.__mul(a, b)
    local aIsVec3 = Vec3.IsVec3(a)
    local bIsVec3 = Vec3.IsVec3(b)
    if aIsVec3 and bIsVec3 then
        ---@cast b Vec3
        return a:Mul(b)
    end

    -- The case when doing <number> * Vec3 a opposed to Vec3 * <number>
    if type(a) == "number" and bIsVec3 then
        return b:Scale(a)
    end

    ---@cast b number
    return a:Scale(b)
end

---Division operator
---@param a Vec3
---@param b Vec3
---@return Vec3
function Vec3.__div(a, b)
    if Vec3.IsVec3(b) then
        return a:Div(b)
    end

    return a:Scale(1 / b)
end

return Vec3
