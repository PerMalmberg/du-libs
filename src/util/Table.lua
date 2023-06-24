---Get the length of the table. Operator "#" does not function on non-arrays or arrays with nil values.
---@param t table
---@return integer
TableLen = function(t)
    local n = 0

    for _ in pairs(t) do
        n = n + 1
    end

    return n
end

---Revereses the list in-place
---@param list any[]
ReverseInplace = function(list)
    local n = #list

    for i = 1, n / 2 do
        list[i], list[n] = list[n], list[i]
        n = n - 1
    end
end

---Copies elements from one list to another
---@param from table
---@param to table
CopyList = function(to, from)
    local start = #to
    for i, item in ipairs(from) do
        to[start + i] = item
    end
end

-- http://lua-users.org/wiki/CopyTable
-- It is important that only one argument is supplied to this version of the deepcopy function.
-- Otherwise, it will attempt to use the second argument as a table, which can have unintended consequences.
local function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---Deeply copies the provided table
---@generic T
---@param o T
---@return T
DeepCopy = function(o)
    return deepcopy(o)
end
