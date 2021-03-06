local HelpMenu = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

local Client = Player.PlayerScripts.Client

local SidePanelHud = require(Client.MainGui.SidePanelHud)

local hideTi = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

function HelpMenu.Activate()
    local lastMenu = SidePanelHud.currMenu
    SidePanelHud.HideCurrMenu()
    if HelpMenu == lastMenu then return end

    SidePanelHud.currMenu = HelpMenu

    local currentPosition = HelpMenu.Menu.Position
    HelpMenu.Menu.Position = UDim2.new(HelpMenu.Menu.Position.X.Scale, 0, 2, 0)
    HelpMenu.Menu.Visible = true

    TweenService:Create(HelpMenu.Menu, SidePanelHud.ti, {Position = currentPosition}):Play()
end

function HelpMenu.Deactivate()
    SidePanelHud.TweenMenuAway(HelpMenu.Menu)
    SidePanelHud.currMenu = nil
end

function HelpMenu.Init()
    HelpMenu.ui = playerGui:WaitForChild("PlayerUI")
    HelpMenu.Menu = HelpMenu.ui.Menus.HelpMenu

    SidePanelHud.BindButton("Help", HelpMenu.Activate)
    HelpMenu.Menu.Exit.MouseButton1Down:Connect(SidePanelHud.HideCurrMenu)
end


return HelpMenu