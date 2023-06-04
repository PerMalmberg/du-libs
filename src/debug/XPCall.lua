local XPCall = {}
XPCall.__index = XPCall

XPCall.Call = function(entryName, f, ...)
    local status, err, _ = xpcall(f, traceback, ...)
    if not status then
        system.print("Error in call from " .. entryName)
        system.print(err)
        unit.exit()
    end
end

return XPCall
