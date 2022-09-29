require("environment"):Prepare()

local Universe = require("universe/Universe")
local Position = require("universe/Position")
local Vec3 = require("cpml/vec3")

local u
local positionOnAlioth
local positionAboveMarket6
local positionNearJago
local positionNearTalemai
local positionNearThades
local positionAboveIon
local market6Pad
local sveaBaseSWSide

setup(function()
    u = Universe.Instance()
    positionOnAlioth = u:ParsePosition("::pos{0,2,7.7093,78.0806,34.7991}")
    positionAboveMarket6 = u:ParsePosition("::pos{0,2,35.9160,101.2832,132000.2500}")
    positionNearJago = u:ParsePosition("::pos{0,0,-102232240.0000,36433324.0000,11837611.0000}")
    positionNearTalemai = u:ParsePosition("::pos{0,0,-10126823.0000,53124664.0000,-14922930.0000}")
    positionNearThades = u:ParsePosition("::pos{0,0,37979880.0000,17169778.0000,-2641396.2500}")
    positionAboveIon = u:ParsePosition("::pos{0,0,2970018.8563,-98961141.3186,-787105.8790}")
    market6Pad = u:ParsePosition("::pos{0,2,36.0242,101.2872,231.3857}")
    sveaBaseSWSide = u:ParsePosition("::pos{0,2,7.5425,78.0995,47.6314}")
end)


describe("Universe", function()
    it("Can create a Position", function()
        local p = Position.New(u:CurrentGalaxy(), u:ClosestBody(positionOnAlioth:Coordinates()), Vec3(1, 2, 3))
        local p2 = Position.New(u:CurrentGalaxy(), u:ClosestBody(positionOnAlioth:Coordinates()), Vec3(3, 4, 5))
        assert.are_equal(Vec3(1, 2, 3):len(), p:Coordinates():len())
        assert.are_equal("Alioth", p.Body.Name)
        assert.are_equal(Vec3(3, 4, 5):len(), p2.Coords:len())
    end)

    it("Can parse positions", function()
        assert.are_equal("::pos{0,2,7.7093,78.0806,34.7991}", tostring(positionOnAlioth))
        assert.are_equal("::pos{0,2,35.9160,101.2832,132000.2500}", tostring(positionAboveMarket6))
        assert.are_equal("::pos{0,0,-102232240.0000,36433324.0000,11837611.0000}", tostring(positionNearJago))
        assert.are_equal("::pos{0,0,-10126823.0000,53124664.0000,-14922930.0000}", tostring(positionNearTalemai))
        assert.are_equal("::pos{0,0,37979880.0000,17169778.0000,-2641396.2500}", tostring(positionNearThades))
        assert.are_equal("::pos{0,0,2970018.8563,-98961141.3186,-787105.8790}", tostring(positionAboveIon))
        assert.are_equal("::pos{0,2,36.0242,101.2872,231.3857}", tostring(market6Pad))
        assert.are_equal("::pos{0,2,7.5425,78.0995,47.6314}", tostring(sveaBaseSWSide))

        assert.are_equal((positionOnAlioth.Coords - positionOnAlioth.Coords):len(), 0)
        assert.are_equal(math.floor((sveaBaseSWSide.Coords - market6Pad.Coords):len()), 76934)
    end)

    it("Can reconstruct a position", function()
        local coordinate = positionOnAlioth.Coords
        local reconstructed = u:CreatePos(coordinate)
        assert.are_equal(tostring(reconstructed), tostring(positionOnAlioth))
    end)
end)



--[[






local test = {}

function test.testPosition()

end

function test.testParsePosition()

end

function test.testCreatePos()

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


]]
