require("link_elements")
require("skill_levels")

function getContainerDataFromHitpoints(containerId)
    local maxHitPoints = linkedCore.getElementMaxHitPointsById(containerId)

    local o = {}

    if maxHitPoints >= 69267 then
        -- XXL
        o.mass = 884013
        o.capacity = adjustContainerVolume(512000)
    elseif maxHitPoints >= 34633 then
        -- XL
        o.mass = 44206
        o.capacity = adjustContainerVolume(256000)
    elseif maxHitPoints >= 17316 then
        -- L
        o.mass = 14842.7
        o.capacity = adjustContainerVolume(128000)
    elseif maxHitPoints >= 7997 then
        -- M
        o.mass = 7421.35
        o.capacity = adjustContainerVolume(64000)
    elseif maxHitPoints >= 999 then
        -- S
        o.mass = 1281.31
        o.capacity = adjustContainerVolume(8000)
    else
        -- xs
        o.mass = 229.09
        o.capacity = adjustContainerVolume(1000)
    end

    return o
end

function calculateActualMass(mass)
    local lvl = getContainerOptimizationLevel()

    if lvl > 0 then
       mass = mass / (1 - lvl * 0.05)
    end

    return mass
end

function adjustContainerVolume(volume)
    local perLevel = 0.1

    local lvl = getContainerProficiencyLevel()

    if lvl > 0 then
        volume = volume * (1 + lvl * perLevel)
    end

    return volume
end

function get_containers(byName)
    linkElements()

    local byContainerName = byName or false

    local containers = {}
    local element_ids = linkedCore.getElementIdList()

    for _, id in pairs(element_ids) do
        if linkedCore.getElementTypeById(id) == "Container" then
      
            local contData = getContainerDataFromHitpoints(id)

            -- The mass we get here is adjusted for skills applied to the container.
            local reducedMass = linkedCore.getElementMassById(id) - contData.mass

            local container_info = {
                "id", "name", "content_reduced_mass", "content_actual_mass", "capacity",
                id = id,
                name = linkedCore.getElementNameById(id),
                content_reduced_mass = reducedMass,
                content_actual_mass = calculateActualMass(reducedMass),
                capacity = contData.capacity
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

