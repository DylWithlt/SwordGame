local InventoryMenu = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

local Client = Player.PlayerScripts.Client

local SidePanelHud = require(Client.MainGui.SidePanelHud)

function InventoryMenu.Activate()
    local lastMenu = SidePanelHud.currMenu
    SidePanelHud.HideCurrMenu()
    if InventoryMenu.Menu == lastMenu then return end

    SidePanelHud.currMenu = InventoryMenu.Menu

    local currentPosition = InventoryMenu.Menu.Position
    InventoryMenu.Menu.Position = UDim2.new(InventoryMenu.Menu.Position.X.Scale, 0, 2, 0)
    InventoryMenu.Menu.Visible = true

    TweenService:Create(InventoryMenu.Menu, SidePanelHud.ti, {Position = currentPosition}):Play()
end

function InventoryMenu.Init()
    InventoryMenu.ui = playerGui:WaitForChild("PlayerUI")
    InventoryMenu.Menu = InventoryMenu.ui.Menus.InventoryMenu

    SidePanelHud.BindButton("Inventory", InventoryMenu.Activate)
    InventoryMenu.Menu.Exit.MouseButton1Down:Connect(SidePanelHud.HideCurrMenu)
end


return InventoryMenu