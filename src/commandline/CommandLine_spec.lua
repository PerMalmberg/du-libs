require("environment"):Prepare()
local CommandLine = require("commandline/CommandLine")

describe("Command line tests", function()
    it("Can take a single command without parameters", function()
        local executed = false
        local cmd = CommandLine.Instance()
        cmd.Accept("test", function(data)
            executed = true
        end)

        system:triggerEvent("onInputText", "wrong command")
        assert.is_false(executed)
        system:triggerEvent("onInputText", "test")
        assert.is_true(executed)
    end)
end)
