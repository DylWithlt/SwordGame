local SidePanelHud = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Util = require(ReplicatedStorage.Common.Util)

-- Variables
local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local buttonsShown = false

local panelButtonBinds = {}

SidePanelHud.currMenu = nil
local tweenTime = 0.25
local hideTi = TweenInfo.new(tweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

function SidePanelHud.BindButton(buttonName, func, menu)
    -- Find Gui Button
    local button = SidePanelHud.Panel.Buttons:FindFirstChild(buttonName)
    if not button then warn(string.format("Invalid button name when trying to bind on Side Panel: %s", buttonName)) return end

    button = button.Button

    if not func then return end

    table.insert(panelButtonBinds, button.MouseButton1Down:Connect(func))
end

function SidePanelHud.HideCurrMenu() -- TODO: Make it call Deactivate Instead.
    if not SidePanelHud.currMenu then return end
    
    if not SidePanelHud.currMenu.Deactivate then return end
    SidePanelHud.currMenu.Deactivate()
end

function SidePanelHud.TweenMenuAway(gui)
    local lastPosition = gui.Position
    local tween = TweenService:Create(gui, hideTi, {Position = UDim2.new(gui.Position.X.Scale, 0, 2, 0)})
    tween:Play()

    tween.Completed:Wait()
    if tween.PlaybackState == Enum.PlaybackState.Cancelled then return end

    gui.Visible = false
    gui.Position = lastPosition
end

function SidePanelHud.Init()
    SidePanelHud.ti = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    SidePanelHud.ui = playerGui:WaitForChild("PlayerUI")
    SidePanelHud.Panel = SidePanelHud.ui.SidePanel

    UserInputService.InputChanged:Connect(function(input, gpe)
        if gpe then return end

        if not (input.UserInputType == Enum.UserInputType.MouseMovement) then return end

        local p = UserInputService:GetMouseLocation()
        local vps = camera.ViewportSize
        local mousePosScale = p.X/vps.X

        if mousePosScale < .35 and buttonsShown == false then
            buttonsShown = true
            TweenService:Create(SidePanelHud.Panel, SidePanelHud.ti, {Position = UDim2.new(0,0,0.5,0)}):Play()
        end

        if mousePosScale > .35 and buttonsShown == true then
            buttonsShown = false
            TweenService:Create(SidePanelHud.Panel, SidePanelHud.ti, {Position = UDim2.new(-0.04,0,0.5,0)}):Play()
        end
    end)

   Util.InitializeChildren(script)
end

return SidePanelHud