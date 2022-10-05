---Get the lenth of the table. Operator "#" does not function on non-arrays or arrays with nil values.
---@param t table
---@return integer
function TableLen(t)
    local n = 0

    for _ in pairs(t) do
        n = n + 1
    end

    return n
end
