local MainGui = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Common.Util)

function MainGui.Init()
    Util.InitializeChildren(script)
end

return MainGui