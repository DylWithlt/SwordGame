local ts = game:GetService("TweenService")
local players = game:GetService("Players")

local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local PlayerHud = {}

local util = require(game.ReplicatedStorage.Common.Util)
local userDataChangedRemote = util.awaitRemote("userDataChanged")

function PlayerHud.Init()
    local logLevel = 0

    --Get UI----------------------------------------------------------------

    PlayerHud.ui = playerGui:WaitForChild("PlayerUI")
	PlayerHud.hud = PlayerHud.ui:WaitForChild("PlayerHud")
	PlayerHud.sounds = PlayerHud.ui:WaitForChild("Sounds")
	PlayerHud.clones = PlayerHud.ui:WaitForChild("Clones")
    
    for _,v in ipairs(PlayerHud.hud:GetChildren()) do
        PlayerHud[v.Name] = v
    end
    ------------------------------------------------------------------------

	userDataChangedRemote.OnClientEvent:Connect(function(data) -- update ui when data is changed\
		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then return end

        --// Displays Health //--
        local playerHealth = humanoid.Health
        local playerHealthScale = humanoid.Health / humanoid.MaxHealth
        
        PlayerHud.PlayerHealthBar.HpBar.Size = UDim2.new(playerHealthScale, 0,2,0)
        PlayerHud.PlayerHealthBar.Health.Text = math.floor(playerHealth)

        --// displays exp, max exp, and level //--
        local expScale = math.clamp(data.exp.current / data.exp.goal, 0, data.exp.goal)
        PlayerHud.PlayerLevelBar.ExpBar:TweenSize(UDim2.new(expScale, 0, 2, 0) , Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.35, true)
        
        PlayerHud.PlayerLevelBar.ExpCurrent.Text = data.exp.current
        PlayerHud.PlayerLevelBar.ExpTotal.Text = data.exp.goal
        
        PlayerHud.PlayerLevelBar.LevelDisplay.Text = 'LEVEL: <font color="rgb(205, 255, 225)">' .. data.level .. '</font>'

        if data.level > logLevel and logLevel ~= 0 then
            PlayerHud.levelUp(data.level)
        end
        logLevel = data.level
    end)
end

function PlayerHud.levelUp(levelReached)
    local effectClone = PlayerHud.LevelUpScreen:Clone()
    local numbers = string.split(levelReached, "")

    for i,v in ipairs(numbers) do
        local imageNumber = effectClone.numbers:FindFirstChild(tostring(v)):Clone()
        imageNumber.Parent = effectClone.DisplayLevel
        imageNumber.Visible = true
    end

    effectClone.Parent = PlayerHud.clones
    effectClone.Visible = true

    PlayerHud.Sounds.LevelUp:Play()
    PlayerHud.Sounds.Bass:Play()
    
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

return PlayerHud