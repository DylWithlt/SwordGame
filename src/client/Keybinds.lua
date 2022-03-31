local Keybinds = {}

local CAS = game:GetService("ContextActionService")

Keybinds.Binds = {}

function Keybinds.BindKey(actionName, func, touchButton, ...)
    Keybinds.Binds[actionName] = CAS:BindAction(actionName, func, touchButton, ...)
end

return Keybinds