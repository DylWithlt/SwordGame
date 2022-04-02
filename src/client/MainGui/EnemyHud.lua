local EnemyHUD = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Modules
local EnemyData = require(ReplicatedStorage.Common.Data.EnemyData)

-- Constants
local VIEW_RANGE = 250

-- Variables
local camera = game.Workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local viewRayParams = RaycastParams.new()
viewRayParams.FilterType = Enum.RaycastFilterType.Blacklist
viewRayParams.IgnoreWater = true


-- Finds the enemy closest to the center of the screen, that is also on the screen.
local function getEnemyOnScreen()
	local closestValue = math.huge
	local currentTarget
	local enemies = workspace.Enemies:GetChildren()

	for _,enemy in ipairs(enemies) do
		if not enemy:IsA("Model") then continue end

		local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
		if (not enemyHumanoid) or enemyHumanoid.Health <= 0 then continue end

		viewRayParams.FilterDescendantsInstances = {player.Character, enemy, workspace.Ignore}
		local ray = workspace:Raycast(camera.CFrame.Position, (enemy.PrimaryPart.Position - camera.CFrame.Position).Unit * (camera.CFrame.Position - enemy.PrimaryPart.Position).Magnitude, viewRayParams)
		local pos, onScreen = camera:WorldToScreenPoint(enemy.PrimaryPart.Position)

		if ray or not onScreen then continue end

		local center = camera.ViewportSize / 2
		local screenPoint = Vector2.new(pos.X, pos.Y)
		local dist = (screenPoint - center).Magnitude

		if pos.Z < VIEW_RANGE and dist < closestValue then
			closestValue = dist
			currentTarget = enemyHumanoid
		end
	end

	return currentTarget
end

local function GetUiSettings(currentUi)
    local tbl = {}
	for _, guiObj in ipairs(currentUi:GetDescendants()) do
		if not guiObj:IsA("GuiObject") then continue end

		local savedSettings = {object = guiObj; settings = {}}

		if guiObj:IsA("Frame") then
			savedSettings.settings.BackgroundTransparency = guiObj.BackgroundTransparency
			guiObj.BackgroundTransparency = 1
		elseif guiObj:IsA("ImageLabel") then
			savedSettings.settings.BackgroundTransparency = guiObj.BackgroundTransparency
			savedSettings.settings.ImageTransparency = guiObj.ImageTransparency
			guiObj.BackgroundTransparency = 1
			guiObj.ImageTransparency = 1
		elseif guiObj:IsA("UIStroke") then
			savedSettings.settings.Transparency =  guiObj.Transparency
			guiObj.Transparency = 1
		elseif guiObj:IsA("TextLabel") then
			savedSettings.settings.BackgroundTransparency = guiObj.BackgroundTransparency
			savedSettings.settings.TextTransparency = guiObj.TextTransparency
			savedSettings.settings.TextStrokeTransparency = guiObj.TextStrokeTransparency
			guiObj.BackgroundTransparency = 1
			guiObj.TextTransparency = 1
			guiObj.TextStrokeTransparency = 1
		end

		table.insert(tbl, savedSettings)
	end

	currentUi.BackgroundTransparency = 1
    return tbl
end

function EnemyHUD.Init()
    local lastEnemy = nil
    EnemyHUD.currentEnemy = nil

    --Get UI----------------------------------------------------------------

    EnemyHUD.ui = playerGui:WaitForChild("PlayerUI")
    EnemyHUD.hud = EnemyHUD.ui:WaitForChild("EnemyHud")
	EnemyHUD.sounds = EnemyHUD.ui:WaitForChild("Sounds")
	EnemyHUD.clones = EnemyHUD.ui:WaitForChild("Clones")

    for _,v in ipairs(EnemyHUD.hud:GetChildren()) do
        EnemyHUD[v.Name] = v
    end
    ------------------------------------------------------------------------

    EnemyHUD.enemyUiSettings = GetUiSettings(EnemyHUD.hud.EnemyBar)
    EnemyHUD.bossUiSettings = GetUiSettings(EnemyHUD.hud.BossBar)

	EnemyHUD.enemyIcons = {
		EnemyHUD.hud.BossBar.DifficulyDisplay.BossIcon,
		EnemyHUD.hud.BossBar.DifficulyDisplay.DemonIcon,
        EnemyHUD.hud.BossBar.DifficulyDisplay.DevilIcon
	}
    
    RunService.RenderStepped:Connect(function()
        EnemyHUD.currentEnemy = getEnemyOnScreen()
        if EnemyHUD.currentEnemy ~= lastEnemy then
            EnemyHUD.updateEnemyDisplay()
		end
		lastEnemy = EnemyHUD.currentEnemy
    end)
end

local currentEnemyUi = nil
local onHealthChanged = nil

local function fadeOutEnemyDisplay()
    if not currentEnemyUi then return end

    local ti = TweenInfo.new(0.15, Enum.EasingStyle.Linear)

	local oldUi = currentEnemyUi
	for _, v in ipairs(oldUi:GetDescendants()) do
		if v:IsA("Frame") then
			TweenService:Create(v, ti, {BackgroundTransparency = 1}):Play()
		elseif v:IsA("ImageLabel") then
			TweenService:Create(v, ti, {BackgroundTransparency = 1, ImageTransparency = 1}):Play()
		elseif v:IsA("UIStroke") then
			TweenService:Create(v, ti, {Transparency = 1}):Play()
		elseif v:IsA("TextLabel") then
			TweenService:Create(v, ti, {BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1}):Play()
		end
	end

    local tween = TweenService:Create(oldUi, ti, {BackgroundTransparency = 1})
	tween:Play()
	tween.Completed:Wait()
end

local function fadeInEnemyDisplay(uiSettings)
	if not currentEnemyUi then return end

	local ti = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
    
	for _, v in ipairs(uiSettings) do
		if v.object:IsA("Frame") then
			TweenService:Create(v.object, ti, v.settings):Play()
		elseif v.object:IsA("ImageLabel") then
			TweenService:Create(v.object, ti, v.settings):Play()
		elseif v.object:IsA("UIStroke") then
			TweenService:Create(v.object, ti, v.settings):Play()
		elseif v.object:IsA("TextLabel") then
			TweenService:Create(v.object, ti, v.settings):Play()
		end

		TweenService:Create(currentEnemyUi, ti, {BackgroundTransparency = 0.5}):Play()
	end
end

function EnemyHUD.updateEnemyDisplay()
    if onHealthChanged then
		onHealthChanged:Disconnect()
	end
    
	EnemyHUD.DisplayEnemyLevel.Visible = false

    fadeOutEnemyDisplay()

	local currentTarget = EnemyHUD.currentEnemy
	if not currentTarget then return end

	local enemy = currentTarget.Parent
	local data = EnemyData[enemy.Name] or EnemyData.Default

	for _, icon in pairs(EnemyHUD.enemyIcons) do
		icon.Visible = false
	end

	local isBoss = data.EnemyType > 0

	if isBoss then -- TODO Make this not clone and instead get the already generated one.
		currentEnemyUi = EnemyHUD.hud.BossBar
		currentEnemyUi.MaxHealth.Text = currentTarget.MaxHealth
		EnemyHUD.enemyIcons[data.EnemyType].Visible = true
    else
        currentEnemyUi = EnemyHUD.hud.EnemyBar
	end

	fadeInEnemyDisplay(isBoss and EnemyHUD.bossUiSettings or EnemyHUD.enemyUiSettings)

	currentEnemyUi.Visible = true
	EnemyHUD.DisplayEnemyLevel.Visible = true

	currentEnemyUi.NameDisplay.Text = enemy.Name
	EnemyHUD.DisplayEnemyLevel.Text = data.Level

	currentEnemyUi.HealthBar.Size = UDim2.new(currentTarget.Health / currentTarget.MaxHealth, 0, 2, 0)
	currentEnemyUi.Health.Text = math.floor(currentTarget.Health)
	onHealthChanged = currentTarget.HealthChanged:Connect(function(h)
		local p = h / currentTarget.MaxHealth
		currentEnemyUi.HealthBar:TweenSize(UDim2.new(p, 0, 2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)

		currentEnemyUi.HealthBar.HealthChanged.Text = math.floor(tonumber(currentEnemyUi.Health.Text) - h)
		currentEnemyUi.HealthBar.HealthChanged.Visible = true

		currentEnemyUi.Health.Text = math.floor(h)

		currentEnemyUi.HealthBar.HealthChanged.TextTransparency = 0
		currentEnemyUi.HealthBar.HealthChanged.Line.BackgroundTransparency = 0

		local ti = TweenInfo.new(0.9, Enum.EasingStyle.Linear)
		TweenService:Create(currentEnemyUi.HealthBar.HealthChanged, ti, {TextTransparency = 1}):Play()
		local fadeTween = TweenService:Create(currentEnemyUi.HealthBar.HealthChanged.Line, ti, {BackgroundTransparency = 1})
		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			if fadeTween.PlaybackState ~= Enum.PlaybackState.Cancelled then
				currentEnemyUi.HealthBar.HealthChanged.Visible = false
			end
		end)
	end)
end

return EnemyHUD