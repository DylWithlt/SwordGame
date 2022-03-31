local Util = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

function Util.createRemote(remoteName, type)
    local remote = Instance.new(type)
    remote.Name = remoteName
    remote.Parent = Remotes
    return remote
end

function Util.awaitRemote(remoteName)
    return Remotes:WaitForChild(remoteName, 3)
end

return Util