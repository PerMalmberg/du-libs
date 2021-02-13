require("link_elements")

function getContainerMassFromHitpoints(containerId)
    local maxHitPoints = linkedCore.getElementMaxHitPointsById(containerId)

    if maxHitPoints >= 69267 then
        -- XXL
        return 884013
    elseif maxHitPoints >= 34633 then
        -- XL
        return 44206
    elseif maxHitPoints >= 17316 then
        -- L
        return 14842.7
    elseif maxHitPoints >= 7997 then
        -- M
        return 7421.35
    elseif maxHitPoints >= 999 then
        -- S
        return 1281.31
    else
        -- xs
        return 229.09
    end
end

function get_containers(byName)
    linkElements()

    local byContainerName = byName or false

    local containers = {}
    local element_ids = linkedCore.getElementIdList()

    for _, id in pairs(element_ids) do
        if linkedCore.getElementTypeById(id) == "Container" then
      
            local container_info = {
                "id", "name", "content_mass",
                id = id,
                name = linkedCore.getElementNameById(id),
                content_mass = linkedCore.getElementMassById(id) - getContainerMassFromHitpoints(id)
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

