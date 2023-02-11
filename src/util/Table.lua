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
CopyTable = function(to, from)
    local start = #to
    for i, item in ipairs(from) do
        to[start + i] = item
    end
end
