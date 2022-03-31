local UserManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Common.Util)

local updateUserRemote = Util.awaitRemote("UpdateUser")

UserManager.UpdateBinds = {}

function UserManager.Init()
    updateUserRemote.OnClientEvent:Connect(function(data)
        for _, bind in ipairs(UserManager.UpdateBinds) do
           bind(data)
        end
    end)
end

function UserManager.BindUpdate(func)
    table.insert(UserManager.UpdateBinds, func)
end

return UserManager