ElementManager = {}

local instance = nil

function ElementManager:Instance()
    if instance == nil then

        instance = {}
        setmetatable(instance, self)
        self.__index = self

        instance.Core = nil
        instance.Screen = {}
        instance.Container = {}
        instance.Switch = {}
        instance.Button = {}
        instance.Emitter = {}
        instance.Receiver = {}
        instance.Light = {}
        instance.Industry = {}
        instance.Databank = {}
        instance.Emitter = {}

        instance.slots = {slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9, slot10}
        instance.linked = false
    end

    instance:link()

    return instance
end

function ElementManager:link()
    if not self.linked then
        for i = 1, #self.slots do
            local slot = self.slots[i]
            if slot ~= nil then
                local elementClass = slot.getElementClass()
                
                if elementClass == 'CoreUnitStatic'
                or elementClass == 'CoreUnitSpace'
                or elementClass == 'CoreUnitDynamic' then
                    self.Core = slot
                elseif (elementClass == 'ScreenUnit') then
                    table.insert(self.Screen, #self.Screen + 1, slot)
                elseif (elementClass == 'ItemContainer') then
                    table.insert(self.Container, #self.Container + 1, slot)
                elseif (elementClass == 'ManualSwitchUnit') then
                    table.insert(self.Switch, #self.Switch + 1, slot)
                elseif (elementClass == 'ManualButtonUnit') then
                    table.insert(self.Button, #self.Button + 1, slot)
                elseif (elementClass == 'EmitterUnit') then
                    table.insert(self.Emitter, #self.Emitter + 1, slot)
                elseif (elementClass == 'ReceiverUnit') then
                    table.insert(self.Receiver, #self.Receiver + 1, slot)
                elseif (elementClass == 'LightUnit') then
                    table.insert(self.Light, #self.Light + 1, slot)
                elseif (elementClass == 'IndustryUnit') then
                    table.insert(self.Industry, #self.Industry + 1, slot)
                elseif (elementClass == 'DataBankUnit') then
                    table.insert(self.Databank, #self.Databank + 1, slot)
                elseif (elementClass == 'Emitter') then
                    table.insert(self.Emitter, #self.Emitter + 1, slot)
                else                
                    system.print(elementClass)
                end
            end
        end

--[[        system.print("Found elements:")        
        system.print("Core:      " .. tostring(self.Core ~= nil))
        system.print("Screen:    " .. #self.Screen)
        system.print("Container: " .. #self.Container)
        system.print("Switch:    " .. #self.Switch)
        system.print("Button:    " .. #self.Button)
        system.print("Emitter:   " .. #self.Emitter)
        system.print("Receiver:  " .. #self.Receiver)
        system.print("Light:     " .. #self.Light)
        system.print("Industry:  " .. #self.Industry)
        system.print("Databank:  " .. #self.Databank)
]]

        linked = true
    end
end

function ElementManager:GetElementNameOfSlot(slot)
    return self.Core.getElementNameById(slot.getId())
end

function ElementManager:GetElementByName(name)
    local element = nil

    for i, s in ipairs(self.slots) do
        if s ~= nil then
            if name == self:GetElementNameOfSlot(s) then
                element = s
                break
            end
        end
    end

    return element
end

function ElementManager:IsDatabank(slot)
    local elementClass = slot.getElementClass()
    return elementClass == "DataBankUnit"   
end

function ElementManager:IsScreen(slot)
    local elementClass = slot.getElementClass()
    return elementClass == "ScreenUnit"   
end