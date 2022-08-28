local XPCall = {}
XPCall.__inded = XPCall

XPCall.Call = function(entryName, f, ...)
    local status, err, _ = xpcall(f, traceback, ...)
    if not status then
        system.print("Error in call from " .. entryName)
        system.print(err)
        unit.exit()
    end
end

return XPCall