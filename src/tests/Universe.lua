local Universe = require("universe/Universe")
local Position = require("universe/Position")
local Vec3 = require("cpml/vec3")
local library = require("abstraction/Library")()
local checks = require("debug/Checks")
local log = require("debug/Log")()

local core = library.GetCoreUnit()

local u = Universe()

local positionOnAlioth = u:ParsePosition("::pos{0,2,7.7093,78.0806,34.7991}")
local positionAboveMarket6 = u:ParsePosition("::pos{0,2,35.9160,101.2832,132000.2500}")
local positionNearJago = u:ParsePosition("::pos{0,0,-102232240.0000,36433324.0000,11837611.0000}")
local positionNearTalemai = u:ParsePosition("::pos{0,0,-10126823.0000,53124664.0000,-14922930.0000}")
local positionNearThades = u:ParsePosition("::pos{0,0,37979880.0000,17169778.0000,-2641396.2500}")
local positionAboveIon = u:ParsePosition("::pos{0,0,2970018.8563,-98961141.3186,-787105.8790}")
local market6Pad = u:ParsePosition("::pos{0,2,36.0242,101.2872,231.3857}")
local sveaBaseSWSide = u:ParsePosition("::pos{0,2,7.5425,78.0995,47.6314}")

local test = {}

function test.testPosition()
    local p = Position(u:CurrentGalaxy(), u:ClosestBody(positionOnAlioth:Coords()), 1, 2, 3)
    local p2 = Position(u:CurrentGalaxy(), u:ClosestBody(positionOnAlioth:Coords()), 3, 4, 5)
    checks.Equals(p.Coords:len(), Vec3(1, 2, 3):len())
    checks.Equals(p.Body.Name, "Alioth")
    checks.Equals(p2.Coords:len(), Vec3(3, 4, 5):len())
end

function test.testParsePosition()
    checks.Equals(tostring(positionOnAlioth), "::pos{0,2,7.7093,78.0806,34.7991}")
    checks.Equals(tostring(positionAboveMarket6), "::pos{0,2,35.9160,101.2832,132000.2500}")
    checks.Equals(tostring(positionNearJago), "::pos{0,0,-102232240.0000,36433324.0000,11837611.0000}")
    checks.Equals(tostring(positionNearTalemai), "::pos{0,0,-10126823.0000,53124664.0000,-14922930.0000}")
    checks.Equals(tostring(positionNearThades), "::pos{0,0,37979880.0000,17169778.0000,-2641396.2500}")
    checks.Equals(tostring(positionAboveIon), "::pos{0,0,2970018.8563,-98961141.3186,-787105.8790}")
    checks.Equals(tostring(market6Pad), "::pos{0,2,36.0242,101.2872,231.3857}")
    checks.Equals(tostring(sveaBaseSWSide), "::pos{0,2,7.5425,78.0995,47.6314}")

    checks.Equals((positionOnAlioth.Coords - positionOnAlioth.Coords):len(), 0)
    checks.Equals(math.floor((sveaBaseSWSide.Coords - market6Pad.Coords):len()), 76934)
end

function test.testCreatePos()
    local coordinate = positionOnAlioth.Coords
    local reconstructed = u:CreatePos(coordinate)
    checks.Equals(tostring(reconstructed), tostring(positionOnAlioth))
end

local status, err, _ = xpcall(function()
    test.testPosition()
    test.testParsePosition()
    test.testCreatePos()
    log:Info("Test complete")
end, traceback)

if not status then
    system.print(err)
end

unit.exit()