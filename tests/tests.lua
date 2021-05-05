require("ElementManager")
require("ContainerManager")
require("SkillManager")
require("string_util")

script = {}

function script.onStart()

    system.print(SkillManager:Instance():ToString())

    local el = ElementManager:Instance()
    assert(el.Core ~= nil, "Core not linked")
    assert(#el.Screen > 0, "Screen not linked")
    assert(#el.Emitter > 0, "Emitter not linked")
    assert(#el.Receiver > 0, "Receiver not linked")
    assert(#el.Databank > 0, "Databank not linked")

    assert(el:GetElementByName("foo") == nil, "Should not find element")
    assert(el:GetElementByName("TheCore"), "Should find element")

    local conMgr = ContainerManager:New()
    conMgr:Update()

    local alu = conMgr:GetContainerByName("Aluminium Scrap")
    assert(alu ~= nil, "Aluminium container not found")
    system.print(alu:ToString())
    assert(alu.Capacity == 9600, "Capacity does not match (check skill levels)")
    assert(alu:ItemCount(2.7) == 100, "Wrong item count")
    assert(alu:ItemVolume(1, 2.7) == 100, "Wrong volume")
    assert(round(alu:FillFactor(1, 2.7), 4) == 0.0104, "Wrong fill factor")
    
    local sod = conMgr:GetContainerByName("Sodium Scrap")
    assert(sod ~= nil, "Sodium container not found")
    system.print(sod:ToString())
    assert(sod.Capacity == 9600, "Capacity does not match (check skill levels)")
    assert(sod:ItemCount(0.97) == 50, "Wrong item count")
    assert(sod:ItemVolume(1, 0.97) == 50, "Wrong volume")
    assert(round(sod:FillFactor(1, 0.97), 4) == 0.0052, "Wrong fill factor")

end

script.onStart()