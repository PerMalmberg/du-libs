local calc = require("util/Calc")
local p = {}

---Paginates the list
---@generic T
---@param list T[]
---@param page integer
---@param perPage integer
---@return T[]
function p.Paginate(list, page, perPage)
    if #list == 0 then return {} end

    local totalPages = p.GetPageCount(list, perPage)
    page = calc.Clamp(page, 1, totalPages)

    local startIx = (page - 1) * perPage + 1
    local endIx = startIx + perPage - 1

    local res = {} ---@type string[]
    local ix = 1

    for i = startIx, endIx, 1 do
        res[ix] = list[i]
        ix = ix + 1
    end

    return res
end

---Gets the number of pages we can make out of the list
---@generic T
---@param list T[]
---@param perPage integer
---@return integer
function p.GetPageCount(list, perPage)
    return math.ceil(#list / perPage)
end

return p
