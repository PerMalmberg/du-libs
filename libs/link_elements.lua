linkedCore = nil
linkedScreen = {}
linkedContainer = {}
linkedSwitch = {}
linkedButton = {}
linkedEmitter = {}
linkedReceiver = {}
linkedLight = {}
linkedIndustry = {}
linkedDatabank = {}
linkedEmitter = {}

local elementsLinked = false

local slots = {slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9, slot10}

function linkElements()
    if not elementsLinked then
        for i = 1, #slots do
            if slots[i] ~= nil then
                local elementClass = slots[i].getElementClass()

                if elementClass == 'CoreUnitStatic'
                or elementClass == 'CoreUnitSpace'
                or elementClass == 'CoreUnitDynamic' then
                    linkedCore = slots[i]
                elseif (elementClass == 'ScreenUnit') then
                    table.insert(linkedScreen, #linkedScreen + 1, slots[i])
                elseif (elementClass == 'ItemContainer') then
                    table.insert(linkedContainer, #linkedContainer + 1, slots[i])
                elseif (elementClass == 'ManualSwitchUnit') then
                    table.insert(linkedSwitch, #linkedSwitch + 1, slots[i])
                elseif (elementClass == 'ManualButtonUnit') then
                    table.insert(linkedButton, #linkedButton + 1, slots[i])
                elseif (elementClass == 'EmitterUnit') then
                    table.insert(linkedEmitter, #linkedEmitter + 1, slots[i])
                elseif (elementClass == 'ReceiverUnit') then
                    table.insert(linkedReceiver, #linkedReceiver + 1, slots[i])
                elseif (elementClass == 'LightUnit') then
                    table.insert(linkedLight, #linkedLight + 1, slots[i])
                elseif (elementClass == 'IndustryUnit') then
                    table.insert(linkedIndustry, #linkedIndustry + 1, slots[i])
                elseif (elementClass == 'DataBankUnit') then
                    table.insert(linkedDatabank, #linkedDatabank + 1, slots[i])
                elseif (elementClass == 'Emitter') then
                    table.insert(linkedEmitter, #linkedEmitter + 1, slots[i])
                else                
                    system.print(elementClass)
                end
            end
        end

        elementsLinked = true
    end
end

function isScreen(slot)
    res = false
    if slot ~= nil then
        local elementClass = slot.getElementClass()    
        res = elementClass == 'ScreenUnit'
    end

    return res
end

function isDatabank(slot)
    res = false
    if slot ~= nil then
        local elementClass = slot.getElementClass()    
        res = elementClass == 'DataBankUnit'
    end

    return res
end