---@enum
local locales = {
    "en-US",
    "fr-FR",
    "de-DE"
}

---Returns the index of the local
---@return integer
function LocaleIndex()
    local locale = system.getLocale()
    for index, value in ipairs(locales) do
        if locale == value then
            return index
        end
    end

    return 1 -- default to en-US
end
