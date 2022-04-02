local InventoryMenu = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

local camera = workspace.CurrentCamera

local Client = Player.PlayerScripts.Client

local SidePanelHud = require(Client.MainGui.SidePanelHud)
local debounce = false

local Util = require(ReplicatedStorage.Common.Util)

function InventoryMenu.ShiftUIt(vector, shiftedUi)
	for i,v in ipairs(shiftedUi:GetDescendants()) do
		if not v:FindFirstChild("Hide") or v:FindFirstChild("Hide").Value == false then
			local x = math.clamp(vector,0,1)
			if v:FindFirstChild("OpOverride") then
				x = math.clamp(vector, v.OpOverride.Value, 1)
			end
			if v:IsA("Frame") then
				v.BackgroundTransparency = x
			elseif v:IsA("TextButton") or v:IsA("TextLabel") then
				v.TextTransparency = vector
				v.BackgroundTransparency = x
			elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
				v.ImageTransparency = vector
			elseif v:IsA("UIStroke") then
				v.Transparency = x
			end
			
			if x == 1 then
				shiftedUi.Enabled = false
			else
				shiftedUi.Enabled = true
			end
		end
	end
end

InventoryMenu.Activate = Util.debounce(0, function()
    local lastMenu = SidePanelHud.currMenu
    SidePanelHud.HideCurrMenu()
    if InventoryMenu == lastMenu then return end

    SidePanelHud.currMenu = InventoryMenu

    local currentPosition = InventoryMenu.Menu.Position
    InventoryMenu.Menu.Position = UDim2.new(InventoryMenu.Menu.Position.X.Scale, 0, 2, 0)
    InventoryMenu.Menu.Visible = true
    local tween = TweenService:Create(InventoryMenu.Menu, SidePanelHud.ti, {Position = currentPosition})
    
    rs:BindToRenderStep("FadeInventoryUi", 1, function()
        if not Player.Character then return end

        local maskVector = Vector3.new(1, 0, 1)

        local camVector = camera.CFrame.LookVector * maskVector
        local rightVector = camera.CFrame.RightVector * maskVector
        local rootVector = Player.Character.PrimaryPart.CFrame.LookVector * maskVector

        local back = (camVector - rootVector).Magnitude
        local front = ((camVector * -1) - rootVector).Magnitude
        local left = ((rightVector * -1) - rootVector).Magnitude
        local right = ((rightVector) - rootVector).Magnitude

        InventoryMenu.ShiftUIt(back, InventoryMenu.Slots.WeaponsSlot)
        InventoryMenu.ShiftUIt(front, InventoryMenu.Slots.OutfitSlot)
        InventoryMenu.ShiftUIt(left, InventoryMenu.Slots.ModsSlot)
        InventoryMenu.ShiftUIt(right, InventoryMenu.Slots.PotionsSlot)
    end)

    tween:Play()
    tween.Completed:Wait()
end)

InventoryMenu.Deactivate = Util.debounce(0, function()
    for _,v in ipairs(InventoryMenu.Slots:GetChildren()) do
        v.Enabled = false
    end

    rs:UnbindFromRenderStep("FadeInventoryUi")

    SidePanelHud.TweenMenuAway(InventoryMenu.Menu)
    SidePanelHud.currMenu = nil
end)

function InventoryMenu.Init()
    InventoryMenu.ui = playerGui:WaitForChild("PlayerUI")
    InventoryMenu.Menu = InventoryMenu.ui.Menus.InventoryMenu
    InventoryMenu.Slots = InventoryMenu.ui.Slots

    -- Toggle view
    SidePanelHud.BindButton("Inventory", InventoryMenu.Activate)
    InventoryMenu.Menu.Exit.MouseButton1Down:Connect(SidePanelHud.HideCurrMenu)

    -- Create equip slots and handle fading effect
    local character = Player.character
    local characterRoot = character:WaitForChild("HumanoidRootPart", 3)

    local rootAttachemtns = {
        attWeapon = Instance.new("Attachment");
        attPotion = Instance.new("Attachment");
        attMod = Instance.new("Attachment");
        attOutfit = Instance.new("Attachment");
    }

    rootAttachemtns.attWeapon.Name = "WeaponsSlot"
    rootAttachemtns.attPotion.Name = "PotionsSlot"
    rootAttachemtns.attMod.Name = "ModsSlot"
    rootAttachemtns.attOutfit.Name = "OutfitSlot"

    rootAttachemtns.attWeapon.Position = Vector3.new(0,1,1.5)
    rootAttachemtns.attPotion.Position = Vector3.new(3,1,0)
    rootAttachemtns.attMod.Position = Vector3.new(-3,1,0)
    rootAttachemtns.attOutfit.Position = Vector3.new(3,0,-1.5)

    for _,v in pairs(rootAttachemtns) do
        v.Parent = characterRoot
        local slot = InventoryMenu.Slots:FindFirstChild(v.Name)
        slot.Adornee = v
        slot.Enabled = false
    end
end

return InventoryMenu