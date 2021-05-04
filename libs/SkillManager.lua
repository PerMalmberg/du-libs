local containerOptimizationLevel = 0 --export: Container Optimization Level
local containerProficiencyLevel = 0 --export: Container Proficiency Level

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