for _, module in ipairs(script:GetChildren()) do
    if not module:IsA("ModuleScript") then continue end

    module = require(module)

    if not module.Init then continue end
    module.Init()
end