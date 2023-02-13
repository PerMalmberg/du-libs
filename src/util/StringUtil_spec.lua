local SU = require("util/StringUtil")

describe("BeginsWith", function()
    it("Returns true when string starts with prefix", function()
        assert.is_true(SU.StartsWith("abc123", "abc"))
        assert.is_false(SU.StartsWith("Qabc123", "abc"))
    end)
end)
