local containerOptimizationLevel = 0
local containerProficiencyLevel = 0

SkillManager = {}

local skillManagerInstance = nil

function SkillManager:Instance()
    if skillManagerInstance == nil then

        skillManagerInstance = {}
        setmetatable(skillManagerInstance, self)
        self.__index = self
    end

    return skillManagerInstance
end

function SkillManager:CalculateActualMass(reducedMass)
    local mass = reducedMass

    if containerOptimizationLevel > 0 then
       mass = mass / (1 - containerOptimizationLevel * 0.05)
    end

    return mass
end

function SkillManager:ApplyContainerProficency(baseVolume)
    local perLevel = 0.1

    local volume = baseVolume

    if containerProficiencyLevel > 0 then
        volume = volume * (1 + containerProficiencyLevel * perLevel)
    end

    return volume
end

function SkillManager:GetContainerOptimizationLevel()
    return containerOptimizationLevel;
end
   
function SkillManager:GetContainerProficiencyLevel()
    return containerProficiencyLevel
end

function SkillManager:SetContainerOptimizationLevel(lvl)
    containerOptimizationLevel = lvl
end
   
function SkillManager:SetContainerProficiencyLevel(lvl)
    containerProficiencyLevel = lvl
end

function SkillManager:ToString()
    local s = "Container Optimization Level: " .. containerOptimizationLevel .. ", " ..
    "Container Proficiency Level: " .. containerProficiencyLevel
    return s
end