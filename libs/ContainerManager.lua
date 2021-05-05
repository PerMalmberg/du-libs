require("ElementManager")
require("SkillManager")

Container = {}

function Container:New(elementId, core)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.id = elementId
    o.core = core
    o.ElementMass = 0
    o.Capacity = 0
    o.Name = "<Unknown>"
    o.ReducedContentMass = 0
    o.ActualContentMass = 0
    o.ContentVolume = 0

    o:update()

    return o
end

function Container:update()
    self:updateBaseData()

    -- The mass we get here is adjusted for skills applied to the container.
    self.ReducedContentMass = self.core.getElementMassById(self.id) - self.ElementMass
    skill = SkillManager:Instance()
    self.ActualContentMass = skill:CalculateActualMass(self.ReducedContentMass)
end

function Container:updateBaseData()
    local core = self.core
    local maxHitPoints = core.getElementMaxHitPointsById(self.id)

    skill = SkillManager:Instance()

    if maxHitPoints >= 69267 then
        -- XXL
        self.ElementMass = 884013
        self.Capacity = skill:ApplyContainerProficency(512000)
    elseif maxHitPoints >= 34633 then
        -- XL
        self.ElementMass = 44206
        self.Capacity = skill:ApplyContainerProficency(256000)
    elseif maxHitPoints >= 17316 then
        -- L
        self.ElementMass = 14842.7
        self.Capacity = skill:ApplyContainerProficency(128000)
    elseif maxHitPoints >= 7997 then
        -- M
        self.ElementMass = 7421.35
        self.Capacity = skill:ApplyContainerProficency(64000)
    elseif maxHitPoints >= 999 then
        -- S
        self.ElementMass = 1281.31
        self.Capacity = skill:ApplyContainerProficency(8000)
    else
        -- xs
        self.ElementMass = 229.09
        self.Capacity = skill:ApplyContainerProficency(1000)
    end

    self.Name = core.getElementNameById(self.id)

    return o
end

function Container:ToString()
    local s = self.Name .. ": " .. self.Capacity .. "L" .. 
    " Element mass: " .. self.ElementMass .. "kg, Reduced Content mass: " .. self.ReducedContentMass ..
    " Actual Content Mass: " .. self.ActualContentMass
    return s
end

function Container:ItemCount(weightOfOneItem)
    return self.ActualContentMass / weightOfOneItem
end

function Container:ItemVolume(volumeOfOneItem, weightOfOneItem)
    local count = self:ItemCount(weightOfOneItem)
    return count * volumeOfOneItem
end

function Container:FillFactor(volumeOfOneItem, weightOfOneItem)
    local contentVolume = self:ItemVolume(volumeOfOneItem,weightOfOneItem)
    return contentVolume / self.Capacity
end



ContainerManager = {}

function ContainerManager:New()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    self.containersByName = {}

    return o
end

function ContainerManager:Update()
    local core = ElementManager:Instance().Core

    local element_ids = core.getElementIdList()

    for _, id in pairs(element_ids) do
        if core.getElementTypeById(id) == "Container" then      
            local c = Container:New(id, core)

            self.containersByName[c.Name] = c
         end
    end

    table.sort(self.containersByName,
        function (a, b) return string.lower(a.Name) < string.lower(b.Name) end)

end

function ContainerManager:GetContainerByName(name)
    return self.containersByName[name]
end


