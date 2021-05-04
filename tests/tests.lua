require("ElementManager")
require("ContainerManager")

script = {}

function script.onStart()
    local el = ElementManager:Instance()
    assert(el.Core ~= nil, "Core not linked")
    assert(#el.Screen > 0, "Screen not linked")
    assert(#el.Emitter > 0, "Emitter not linked")
    assert(#el.Receiver > 0, "Receiver not linked")
    assert(#el.Databank > 0, "Databank not linked")

    local conMgr = ContainerManager:New()
    conMgr:Update()

    local alu = conMgr:GetContainerByName("Aluminium Scrap")
    assert(alu ~= nil, "Aluminium container not found")
    system.print(alu:ToString())

    local sod = conMgr:GetContainerByName("Sodium Scrap")
    assert(sod ~= nil, "Sodium container not found")
    system.print(sod:ToString())

end

script.onStart()