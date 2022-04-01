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

function Util.ClearChildrenOfClass(parent, class)
    for _, v in ipairs(parent:GetChildren()) do
        if v:IsA(class) then
            v:Destroy()
        end
    end
end

return Util