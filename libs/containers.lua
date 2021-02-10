require("link_elements")

function get_container_data(name)
    local w = 0
    local n = name

    if name:find("^xxl_") ~= nil then
        w = 884013
    elseif name:find("^xl_") ~= nil then
        w = 44206
    elseif name:find("^l_") ~= nil then
        w = 14842.7
    elseif name:find("^m_") ~= nil then
        w = 7421.35
    elseif name:find("^s_") ~= nil then
        w = 1281.31
    elseif name:find("^xs_") ~= nil then
        w = 229.09
    end
    
    res = {}
    res.weight = w
    res.name = name
    
    return res
end

function get_containers(byName)
    linkElements()

    local byContainerName = byName or false

    local containers = {}
    local element_ids = linkedCore.getElementIdList()

    for _, id in pairs(element_ids) do
        if linkedCore.getElementTypeById(id) == "Container" then
            local container_name = linkedCore.getElementNameById(id)
            local cont_data = get_container_data(container_name)
      
            local container_info = {
                "id", "name", "content_weight",
                id = id,
                name = cont_data.name,
                content_weight = linkedCore.getElementMassById(id) - cont_data.weight
            }

            if byContainerName then
                containers[container_info.name] = container_info
            else
                table.insert(containers, container_info)
            end
         end
    end

    table.sort(containers,
        function (a, b) return string.lower(a.name) < string.lower(b.name) end)

    return containers
end

