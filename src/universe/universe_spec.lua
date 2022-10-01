---@diagnostic disable: need-check-nil
require("environment"):Prepare()
local CoreMock = require("mocks/CoreMock")
local Universe = require("universe/Universe")
local Position = require("universe/Position")
local Vec3 = require("cpml/vec3")
local Ray = require("util/Ray")

local u ---@type Universe
local positionOnAlioth ---@type Position|nil
local positionAboveMarket6 ---@type Position|nil
local positionNearJago ---@type Position|nil
local positionNearTalemai ---@type Position|nil
local positionNearThades ---@type Position|nil
local positionAboveIon ---@type Position|nil
local market6Pad ---@type Position|nil
local sveaBaseSWSide ---@type Position|nil



before_each(function()
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

describe("Singelton", function()
    it("Are the same instance", function()
        assert.are_equal(Universe.Instance(), Universe.Instance())
    end)
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
        assert.are_equal("::pos{0,2,7.7093,78.0806,34.7991}", positionOnAlioth:AsPosString())
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

describe("Body", function()
    it("Can calculate distance to atmo", function()
        local aliCenter = Vec3(-8.00, -8.00, -126303.00)
        local b = u:ClosestBody(aliCenter)
        assert.are_equal("Alioth", tostring(b))
        local point10kmOutsideAtmo = aliCenter + Vec3.unit_x * (b.Atmosphere.Radius + 10000) ---@type Vec3
        assert.are_equal(10000, b:DistanceToAtmo(point10kmOutsideAtmo))
    end)

    it("Can detect if a point is in atmo", function()
        local aliCenter = Vec3(-8.00, -8.00, -126303.00)
        local b = u:ClosestBody(aliCenter)
        assert.are_equal("Alioth", tostring(b))
        local pointInsideAtmo = aliCenter + Vec3.unit_y * (b.Atmosphere.Radius / 2) ---@type Vec3
        assert.is_true(b:IsInAtmo(pointInsideAtmo))
    end)
end)

describe("Detect bodies in flight path", function()
    local aliCenter = Vec3(-8.00, -8.00, -126303.00)
    local b = u:ClosestBody(aliCenter)

    local g = u:CurrentGalaxy()
    local point10kmOutsideAlioth = aliCenter + Vec3.unit_x * (b.Atmosphere.Radius + 10000)
    local ray = Ray.New(point10kmOutsideAlioth, (aliCenter - point10kmOutsideAlioth):normalize())
    local bodies = g:BodiesInPath(ray)
    assert.are_equal(1, #bodies)
    assert.are_equal("Alioth", bodies[1].Name)

    local madisCenter = Vec3(17465536.00, 22665536.00, -34464.00)
    local ray = Ray.New(point10kmOutsideAlioth, (madisCenter - point10kmOutsideAlioth):normalize())
    local bodies = g:BodiesInPath(ray)
    assert.are_equal(1, #bodies)
    assert.are_equal("Madis", bodies[1].Name)
end)

describe("Veritcal reference vector", function()
    it("Can get the vertical reference vector", function()
        local vRef = u:VerticalReferenceVector()
        assert.is_not_nil(vRef.x)
        assert.is_not_nil(vRef.y)
        assert.is_not_nil(vRef.z)

        CoreMock.Instance().SetWorldGravity(Vec3(0, 0, 0))
        local vRef = u:VerticalReferenceVector()
        assert.is_not_nil(vRef.x)
        assert.is_not_nil(vRef.y)
        assert.is_not_nil(vRef.z)
        assert.are_equal(0, vRef.x)
        assert.are_equal(0, vRef.y)
        assert.are_equal(0, vRef.z)
    end)

end)
