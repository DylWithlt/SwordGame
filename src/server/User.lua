local User = {}
User.__index = User

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Util = require(ReplicatedStorage.Common.Util)
local updateUserRemote = Util.createRemote("UpdateUser", "RemoteEvent")

local UserCache = {}

function User.Init()
    Players.PlayerAdded:Connect(function(Player)
        local _user = User.new(Player)
        UserCache[tostring(Player.UserId)] = _user
    end)
end

function User.GetUser(userId)
    return UserCache[userId]
end

function User.new(Player)
    local self = setmetatable({}, User)

    self.Player = Player
    self.Data = {}
    self.Keybinds = {} -- {actionname = "Action", keys = {Enum.KeyCode.A}}

    self:LoadData()
    updateUserRemote:FireClient(self.Player, self.Data)

    return self
end

function User:LoadData()
    -- TODO: Datastore stuff.
    local LoadedData = {} -- insert datastore here
    self.Data = LoadedData
end

return User