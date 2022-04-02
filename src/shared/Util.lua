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

function Util.InitializeChildren(parent)
    for _, module in ipairs(parent:GetChildren()) do
        if not module:IsA("ModuleScript") then continue end

        module = require(module)

        if not module.Init then continue end
        module.Init()
    end
end

function Util.debounce(waitTime, func)
    local db = false

    return function(...)
        if db then return end
        db = true

        func(...)
        if waitTime > 0 then task.wait(waitTime) end

        db = false
    end
end

return Util