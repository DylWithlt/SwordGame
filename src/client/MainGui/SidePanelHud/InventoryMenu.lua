local InventoryMenu = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local rs = game:GetService("RunService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

local camera = workspace.CurrentCamera

local Client = Player.PlayerScripts.Client

local SidePanelHud = require(Client.MainGui.SidePanelHud)

local isOpened = false

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
    InventoryMenu.Slots = InventoryMenu.ui.Slots

    -- Toggle view
    SidePanelHud.BindButton("Inventory", InventoryMenu.Activate)
    InventoryMenu.Menu.Exit.MouseButton1Down:Connect(SidePanelHud.HideCurrMenu)

    -- Create equip slots and handle fading effect
    local character = Player.character
    local characterRoot = character.HumanoidRootPart

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
    
    rs.RenderStepped:Connect(function()
        if InventoryMenu.Menu.Visible then
            isOpened = true
            local camVector = Vector3.new(camera.CFrame.LookVector.X, 0 ,camera.CFrame.LookVector.Z)
            local rightVector = Vector3.new(camera.CFrame.RightVector.X, 0 ,camera.CFrame.RightVector.Z)
            local rootVector = Vector3.new(character.PrimaryPart.CFrame.LookVector.X, 0, character.PrimaryPart.CFrame.LookVector.Z)
    
            local bv = (camVector - rootVector).Magnitude
            local fv = ((camVector * -1) - rootVector).Magnitude
            local lv = ((rightVector * -1) - rootVector).Magnitude
            local rv = ((rightVector) - rootVector).Magnitude
    
            InventoryMenu.ShiftUIt(bv, InventoryMenu.Slots.WeaponsSlot)
            InventoryMenu.ShiftUIt(fv, InventoryMenu.Slots.OutfitSlot)
            InventoryMenu.ShiftUIt(lv, InventoryMenu.Slots.ModsSlot)
            InventoryMenu.ShiftUIt(rv, InventoryMenu.Slots.PotionsSlot)
            
            ---- gets the current slot you are looking at
            -- local t = {sword = bv, outfit = fv, mod = lv, potion = rv}
            -- local currentHValue = math.huge
            -- local cMenu = ""
    
            -- for i,v in pairs(t) do --Gets lowest value
            --     if v < currentHValue then
            --         currentHValue = v
            --         cMenu = i
            --     end
            -- end
    
            -- local stringTable = {}
            -- for i = 1, string.len(cMenu) do
            --     stringTable[i] = string.upper(string.sub(cMenu, i,i))
            -- end
    
            -- local menuTitleString = table.concat(stringTable, "  ")
        elseif isOpened == true then
            isOpened = false
            for _,v in ipairs(InventoryMenu.Slots:GetChildren()) do
                v.Enabled = false
            end
        end
    end)
end


return InventoryMenu