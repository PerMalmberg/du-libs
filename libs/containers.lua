function get_container_data(name)
    local w = 0
    local n = name

    if name:find("^l_") ~= nil then
        w = 14840
        n = name:sub(3, #name)
    elseif name:find("^m_") ~= nil then
        w = 7420
        n = name:sub(3, #name)
    elseif name:find("^s_") ~= nil then
        w = 1280
        n = name:sub(3, #name)
    elseif name:find("^xs_") ~= nil then
        w = 229.09
        n = name:sub(4, #name)
    end
    
    res = {}
    res.weight = w
    res.name = n
    
    return res
end

function get_containers()
    local containers = {}
    local element_ids = core.getElementIdList()

    for _, id in pairs(element_ids) do
        if core.getElementTypeById(id) == "Container" then
            local container_name = core.getElementNameById(id)
            local cont_data = get_container_data(container_name)
      
            if cont_data.weight > 0 then
                local container_info = {
                    "id", "name", "content_weight",
                    id = id,
                    name = cont_data.name,
                    content_weight = core.getElementMassById(id) - cont_data.weight
                }
                table.insert(containers, container_info)
            end
         end
    end

    table.sort(containers,
        function (a, b) return string.lower(a.name) < string.lower(b.name) end)

    return containers
end

