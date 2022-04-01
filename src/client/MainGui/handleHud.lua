local sgui = game:GetService("StarterGui")
local rs = game:GetService("RunService")
local players = game:GetService("Players")

local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local hud = {}
local util = require(ReplicatedStorage.Common.Util)
local userDataChangedRemote = util.awaitRemote("UserDataChanged")

sgui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
sgui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

local function ClearChildrenOfClass(parent, class)
    for i,v in ipairs(parent:GetChildren()) do
        if v:IsA(class) then
            v:Destroy()
        end
    end
end

function hud.init()
    local logLevel = 0
    local logEnemy = nil
    local currentEnemy = nil

    --Get UI----------------------------------------------------------------

    self.ui = playerGui:WaitForChild("PlayerUI")
    self.hud = ui:WaitForChild("PlayerHud")
    self.sounds = ui:WaitForChild("Sounds")
    self.clones = ui:WaitForChild("Clones")
    
    for i,v in ipairs(self.hud:GetChildren()) do
        self[i] = v
    end
    ------------------------------------------------------------------------

    userDataChangedRemote.OnClientEvent:Connect(function(data) -- update ui when data is changed
        --// Displays Health //--
        local playerHealth = humanoid.Health
        local playerHealthScale = humanoid.Health / humanoid.MaxHealth
        
        self.PlayerHealthBar.HpBar.Size = UDim2.new(playerHealthScale, 0,2,0)
        self.PlayerHealthBar.Health.Text = math.floor(playerHealth)
    
        --// displays exp, max exp, and level //--
        local expScale = math.clamp(data.exp.current / data.exp.goal, 0, data.exp.goal)
        self.PlayerLevelBar.ExpBar:TweenSize(UDim2.new(expScale, 0, 2, 0) , Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.35, true)
        
        self.PlayerLevelBar.ExpCurrent.Text = data.exp.current
        self.PlayerLevelBar.ExpTotal.Text = data.exp.goal
        
        self.PlayerLevelBar.LevelDisplay.Text = 'LEVEL: <font color="rgb(205, 255, 225)">' .. data.level .. '</font>'

        if data.level > logLevel and logLevel ~= 0 then
            self.levelUp(data.level)
        end
        logLevel = data.level
    end)

    local onRender = rs.RenderStepped:Connect(function()
        currentEnemy = self:getEnemyOnScreen()
        if currentEnemy ~= logEnemy then
            self.showEnemyUi(currentEnemy)
        end
    end)
    logEnemy = currentEnemy
end

function self.levelUp(levelReached)
    local effectClone = self.LevelUpScreen:Clone()
    local numbers = string.split(levelReached, "")

    for i,v in ipairs(numbers) do
        local imageNumber = effectClone.numbers:FindFirstChild(tostring(v)):Clone()
        imageNumber.Parent = effectClone.DisplayLevel
        imageNumber.Visible = true
    end

    effectClone.Parent = self.clones
    effectClone.Visible = true

    self.sounds.LevelUp:Play()
    self.sounds.Bass:Play()
    
    local effectInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
    local textInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    ts:Create(effectClone.Effect, effectInfo, {Size = UDim2.new(10,0,10,0), ImageTransparency = 1}):Play()
    ts:Create(effectClone, textInfo, {Size = UDim2.new(0.6,0,0.6,0)}):Play()
    task.wait(2)
    ts:Create(effectClone, effectInfo, {ImageTransparency = 1}):Play()

    for i,v in ipairs(effectClone.DisplayLevel:GetChildren()) do
        if v:IsA("ImageLabel") then
            ts:Create(v, effectInfo, {ImageTransparency = 1}):Play()
        end
    end

    task.wait(0.225)
    effectClone:Destroy()
end

function self:getEnemyOnScreen()
	local closestValue = math.huge
	local currentTarget
    local enemies = game.Workspace.Enemies:GetChildren()

	for i,enemy in pairs(enemies) do
		if enemy:IsA("Model") then
            local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
            if (not enemyHumanoid) or enemyHumanoid.Health <= 0 then continue end
			
			viewRayParams.FilterDescendantsInstances = {character, enemy, workspace.Ignore}
			local ray = workspace:Raycast(camera.CFrame.Position, (enemy.PrimaryPart.Position - camera.CFrame.Position).Unit * (camera.CFrame.Position - enemy.PrimaryPart.Position).Magnitude, viewRayParams)
			local pos, onScreen = camera:WorldToScreenPoint(enemy.PrimaryPart.Position)
			
			if ray or not onScreen then continue end
			
			local center = camera.ViewportSize / 2
			local screenPoint = Vector2.new(pos.X, pos.Y)
			local dist = (screenPoint - center).Magnitude
			
			if pos.Z < viewRange and dist < closestValue then
				closestValue = dist
				currentTarget = enemyHumanoid
			end
		end
	end
	
	return currentTarget
end

local currentEnemyUi
local onHealthChanged

function self.showEnemyUi(t)
	local ti = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
	self.EnemyLevelDisplay.Visible = false
	if onHealthChanged then
		onHealthChanged:Disconnect()
	end
	if currentEnemyUi then
		local oldUi = currentEnemyUi
		for i,v in ipairs(oldUi:GetDescendants()) do
			if v:IsA("Frame") then
				ts:Create(v, ti, {BackgroundTransparency = 1}):Play()
			elseif v:IsA("ImageLabel") then
				ts:Create(v, ti, {BackgroundTransparency = 1, ImageTransparency = 1}):Play()
			elseif v:IsA("UIStroke") then
				ts:Create(v, ti, {Transparency = 1}):Play()
			elseif v:IsA("TextLabel") then
				ts:Create(v, ti, {BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			end
		end
		
		ts:Create(oldUi, ti, {BackgroundTransparency = 1}):Play()
		delay(0.75, function()
			oldUi:Destroy()
		end)
	end
	
	if t ~= nil then
		local enemy = t.Parent
		local data = enemy.stats
		
		if data.BossLevel.Value > 0 then
			currentUi = pStats.BossBar:Clone()
			currentUi.MaxHealth.Text = t.MaxHealth
			
			for i,v in ipairs(currentUi.DifficulyDisplay:GetChildren()) do
				v.Visible = false
			end
			if data.BossLevel.Value == 1 then
				currentUi.DifficulyDisplay.BossIcon.Visible = true
			elseif data.BossLevel.Value == 2 then
				currentUi.DifficulyDisplay.DemonIcon.Visible = true
			elseif data.BossLevel.Value == 3 then
				currentUi.DifficulyDisplay.DevilIcon.Visible = true
			end
		else
			currentUi = pStats.EnemyBar:Clone()
		end
		
		local transparencyTable = {}
		for i,v in ipairs(currentUi:GetDescendants()) do
			if v:IsA("Frame") then
				transparencyTable[#transparencyTable + 1] = {v, v.BackgroundTransparency}
				v.BackgroundTransparency = 1
			elseif v:IsA("ImageLabel") then
				transparencyTable[#transparencyTable + 1] = {v, v.BackgroundTransparency, v.ImageTransparency}
				v.BackgroundTransparency = 1
				v.ImageTransparency = 1
			elseif v:IsA("UIStroke") then
				transparencyTable[#transparencyTable + 1] = {v, v.Transparency}
				v.Transparency = 1
			elseif v:IsA("TextLabel") then
				transparencyTable[#transparencyTable + 1] = {v, v.BackgroundTransparency, v.TextTransparency, v.TextStrokeTransparency}
				v.BackgroundTransparency = 1
				v.TextTransparency = 1
				v.TextStrokeTransparency = 1
			end
			
			currentUi.BackgroundTransparency = 1
		end
		
		currentUi.Parent = ui.Clones
		for i,v in ipairs(transparencyTable) do
			if v[1]:IsA("Frame") then
				ts:Create(v[1], ti, {BackgroundTransparency = v[2]}):Play()
			elseif v[1]:IsA("ImageLabel") then
				ts:Create(v[1], ti, {BackgroundTransparency = v[2], ImageTransparency = v[3]}):Play()
			elseif v[1]:IsA("UIStroke") then
				ts:Create(v[1], ti, {Transparency = v[2]}):Play()
			elseif v[1]:IsA("TextLabel") then
				ts:Create(v[1], ti, {BackgroundTransparency = v[2], TextTransparency = v[3], TextStrokeTransparency = v[4]}):Play()
			end
			
			ts:Create(currentUi, ti, {BackgroundTransparency = 0.5}):Play()
		end
		
		currentUi.Visible = true
		self.EnemyLevelDisplay.Visible = true
		
		currentUi.NameDisplay.Text = enemy.Name
		self.EnemyLevelDisplay.Text = data.Level.Value
		
		currentUi.HealthBar.Size = UDim2.new(t.Health / t.MaxHealth, 0, 2, 0)
		currentUi.Health.Text = math.floor(t.Health)
		onHealthChanged = t.HealthChanged:Connect(function(h)
			local p = h / t.MaxHealth
			currentUi.HealthBar:TweenSize(UDim2.new(p, 0, 2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
			
			currentUi.HealthBar.HealthChanged.Text = math.floor(tonumber(currentUi.Health.Text) - h)
			currentUi.HealthBar.HealthChanged.Visible = true
			
			currentUi.Health.Text = math.floor(h)
			
			currentUi.HealthBar.HealthChanged.TextTransparency = 0
			currentUi.HealthBar.HealthChanged.Line.BackgroundTransparency = 0
			
			local ti = TweenInfo.new(0.9, Enum.EasingStyle.Linear)
			ts:Create(currentUi.HealthBar.HealthChanged, ti, {TextTransparency = 1}):Play()
			local fadeTween = ts:Create(currentUi.HealthBar.HealthChanged.Line, ti, {BackgroundTransparency = 1})
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				if fadeTween.PlaybackState ~= Enum.PlaybackState.Cancelled then
					currentUi.HealthBar.HealthChanged.Visible = false
				end
			end)
		end)
	end
end

return hud