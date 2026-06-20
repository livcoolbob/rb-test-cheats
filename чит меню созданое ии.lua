local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ===================== СОЗДАНИЕ GUI =====================
local screenGui = script.Parent
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Главная рамка (панель)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Size = UDim2.new(0, 280, 0, 420)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
mainFrame.Visible = true
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Обводка
local mainStroke = Instance.new("UIStroke")
mainStroke.Parent = mainFrame
mainStroke.Color = Color3.fromRGB(80, 80, 120)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 40)
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = titleBar
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "?? HUB  [RightCtrl]"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка сворачивания
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = titleBar
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 180, 0)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.BorderSizePixel = 0
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

local buttonContainer -- forward-declare, будет определён ниже

local isMinimized = false
local fullSize = UDim2.new(0, 280, 0, 420)
local minSize = UDim2.new(0, 280, 0, 40)

minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = minSize
		}):Play()
		buttonContainer.Visible = false
		minimizeBtn.Text = "?"
	else
		buttonContainer.Visible = true
		TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = fullSize
		}):Play()
		minimizeBtn.Text = "—"
	end
end)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "?"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- Контейнер кнопок
buttonContainer = Instance.new("ScrollingFrame")
buttonContainer.Parent = mainFrame
buttonContainer.Size = UDim2.new(1, -16, 1, -50)
buttonContainer.Position = UDim2.new(0, 8, 0, 44)
buttonContainer.BackgroundTransparency = 1
buttonContainer.ScrollBarThickness = 4
buttonContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
buttonContainer.BorderSizePixel = 0
buttonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
buttonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = buttonContainer
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Функция разделителя категорий
local function createSectionLabel(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 22)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(150, 150, 200)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
end

-- Функция создания кнопки
local function createButton(name, color, icon)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 44)
	btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
	btn.Text = (icon or "") .. "  " .. name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	-- Hover эффект
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(
			math.min(color.R * 1.3, 1),
			math.min(color.G * 1.3, 1),
			math.min(color.B * 1.3, 1)
		)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
	end)

	return btn
end

-- ===================== ДВИЖЕНИЕ =====================
local section1 = createSectionLabel("-- ДВИЖЕНИЕ --")
section1.Parent = buttonContainer

-- ПОЛЁТ (FLY)
local flyBtn = createButton("Полёт (Вкл/Выкл)", Color3.fromRGB(0, 120, 220), "???")
flyBtn.Parent = buttonContainer

local flying = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyConnection = nil
local FLY_SPEED = 60

local function toggleFly()
	character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if flying then
		if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
		if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
		if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
		flying = false
		flyBtn.Text = "???  Полёт (Вкл/Выкл)"
	else
		flyBodyVelocity = Instance.new("BodyVelocity")
		flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		flyBodyVelocity.Velocity = Vector3.zero
		flyBodyVelocity.Parent = hrp

		flyBodyGyro = Instance.new("BodyGyro")
		flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		flyBodyGyro.P = 9000
		flyBodyGyro.Parent = hrp

		flyConnection = RunService.Heartbeat:Connect(function()
			if not flying or not hrp or not hrp.Parent then return end
			local cam = workspace.CurrentCamera
			local cf = cam.CFrame
			local direction = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end

			if direction.Magnitude > 0 then direction = direction.Unit end
			flyBodyVelocity.Velocity = direction * FLY_SPEED
			flyBodyGyro.CFrame = cf
		end)

		flying = true
		flyBtn.Text = "???  Полёт ВКЛ (WASD+Space/Shift)"
	end
end

flyBtn.MouseButton1Click:Connect(toggleFly)

-- СКОРОСТЬ
local speedBtn = createButton("Скорость x3", Color3.fromRGB(0, 200, 200), "?")
speedBtn.Parent = buttonContainer

local speedBoosted = false
local NORMAL_SPEED = 16
local BOOST_SPEED = 48

speedBtn.MouseButton1Click:Connect(function()
	character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if speedBoosted then
		humanoid.WalkSpeed = NORMAL_SPEED
		speedBoosted = false
		speedBtn.Text = "?  Скорость x3"
	else
		humanoid.WalkSpeed = BOOST_SPEED
		speedBoosted = true
		speedBtn.Text = "?  Скорость x3 ВКЛ"
	end
end)

-- NOCLIP
local noclipBtn = createButton("Noclip (сквозь стены)", Color3.fromRGB(200, 180, 0), "??")
noclipBtn.Parent = buttonContainer

local noclipEnabled = false
local noclipConnection = nil

local function toggleNoclip()
	if noclipEnabled then
		if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
		noclipEnabled = false
		noclipBtn.Text = "??  Noclip (сквозь стены)"
		character = player.Character or player.CharacterAdded:Wait()
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	else
		noclipConnection = RunService.Stepped:Connect(function()
			character = player.Character or player.CharacterAdded:Wait()
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end)
		noclipEnabled = true
		noclipBtn.Text = "??  Noclip ВКЛ"
	end
end

noclipBtn.MouseButton1Click:Connect(toggleNoclip)

-- INFINITE JUMP
local infJumpBtn = createButton("Бесконечный прыжок", Color3.fromRGB(100, 60, 200), "??")
infJumpBtn.Parent = buttonContainer

local infJumpEnabled = false
local infJumpConnection = nil

local function toggleInfJump()
	if infJumpEnabled then
		if infJumpConnection then infJumpConnection:Disconnect(); infJumpConnection = nil end
		infJumpEnabled = false
		infJumpBtn.Text = "??  Бесконечный прыжок"
	else
		infJumpConnection = UserInputService.JumpRequest:Connect(function()
			character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
		infJumpEnabled = true
		infJumpBtn.Text = "??  Бесконечный прыжок ВКЛ"
	end
end

infJumpBtn.MouseButton1Click:Connect(toggleInfJump)

-- ФЛИНГ
local flingBtn = createButton("Флинг", Color3.fromRGB(255, 100, 0), "??")
flingBtn.Parent = buttonContainer

flingBtn.MouseButton1Click:Connect(function()
	character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Velocity = hrp.CFrame.LookVector * 250 + Vector3.new(0, 80, 0)
	bv.Parent = hrp
	Debris:AddItem(bv, 0.5)
end)

-- SPINBOT
local spinBtn = createButton("Спинбот", Color3.fromRGB(220, 50, 150), "??")
spinBtn.Parent = buttonContainer

local spinEnabled = false
local spinConnection = nil

local function toggleSpin()
	if spinEnabled then
		if spinConnection then spinConnection:Disconnect(); spinConnection = nil end
		spinEnabled = false
		spinBtn.Text = "??  Спинбот"
	else
		spinConnection = RunService.Heartbeat:Connect(function()
			character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(720 * 0.016), 0)
			end
		end)
		spinEnabled = true
		spinBtn.Text = "??  Спинбот ВКЛ"
	end
end

spinBtn.MouseButton1Click:Connect(toggleSpin)

-- ===================== БОЕВЫЕ =====================
local section2 = createSectionLabel("-- БОЕВЫЕ --")
section2.Parent = buttonContainer

-- GOD MODE
local godBtn = createButton("God Mode (бессмертие)", Color3.fromRGB(200, 50, 50), "???")
godBtn.Parent = buttonContainer

local godEnabled = false
local godConnection = nil

local function toggleGod()
	if godEnabled then
		if godConnection then godConnection:Disconnect(); godConnection = nil end
		godEnabled = false
		godBtn.Text = "???  God Mode (бессмертие)"
	else
		godConnection = RunService.Heartbeat:Connect(function()
			character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
		godEnabled = true
		godBtn.Text = "???  God Mode ВКЛ"
	end
end

godBtn.MouseButton1Click:Connect(toggleGod)

-- KILL ALL
local killAllBtn = createButton("Убить всех", Color3.fromRGB(180, 0, 0), "??")
killAllBtn.Parent = buttonContainer

killAllBtn.MouseButton1Click:Connect(function()
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = 0
			end
		end
	end
end)

-- ===================== ВИЗУАЛ =====================
local section3 = createSectionLabel("-- ВИЗУАЛ --")
section3.Parent = buttonContainer

-- ESP
local espBtn = createButton("ESP (подсветка игроков)", Color3.fromRGB(0, 255, 100), "???")
espBtn.Parent = buttonContainer

local espEnabled = false
local espHighlights = {}

local function toggleESP()
	if espEnabled then
		-- Удалить все хайлайты
		for _, h in pairs(espHighlights) do
			if h then h:Destroy() end
		end
		espHighlights = {}
		espEnabled = false
		espBtn.Text = "???  ESP (подсветка игроков)"
	else
		-- Добавить ESP для текущих игроков
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character then
				local highlight = Instance.new("Highlight")
				highlight.Name = "ESP_Highlight"
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				highlight.Parent = otherPlayer.Character
				espHighlights[otherPlayer.UserId] = highlight
			end
		end
		espEnabled = true
		espBtn.Text = "???  ESP ВКЛ"
	end
end

espBtn.MouseButton1Click:Connect(toggleESP)

-- Обновлять ESP при появлении новых игроков
Players.PlayerAdded:Connect(function(otherPlayer)
	if espEnabled then
		otherPlayer.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			if espEnabled and char then
				local highlight = Instance.new("Highlight")
				highlight.Name = "ESP_Highlight"
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				highlight.Parent = char
				espHighlights[otherPlayer.UserId] = highlight
			end
		end)
	end
end)

-- ЗАМЕНА ТЕКСТУР
local texBtn = createButton("Сменить текстуру мира", Color3.fromRGB(180, 50, 180), "??")
texBtn.Parent = buttonContainer

local materialList = {
	Enum.Material.Neon, Enum.Material.Glass, Enum.Material.ForceField,
	Enum.Material.Ice, Enum.Material.Marble, Enum.Material.DiamondPlate,
	Enum.Material.CorrodedMetal, Enum.Material.Grass, Enum.Material.Slate, Enum.Material.Snow,
}
local materialIndex = 1
local originalMaterials = {}
local materialsApplied = false

local function applyTextureToWorkspace(mat)
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") then
			if not originalMaterials[part] then
				originalMaterials[part] = {material = part.Material, color = part.Color}
			end
			part.Material = mat
			part.Color = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
		end
	end
end

local function restoreOriginalTextures()
	for part, orig in pairs(originalMaterials) do
		if part and part.Parent then
			part.Material = orig.material
			part.Color = orig.color
		end
	end
	originalMaterials = {}
end

texBtn.MouseButton1Click:Connect(function()
	if materialsApplied then
		restoreOriginalTextures()
		materialsApplied = false
		texBtn.Text = "??  Сменить текстуру мира"
	else
		materialIndex = materialIndex % #materialList + 1
		local mat = materialList[materialIndex]
		applyTextureToWorkspace(mat)
		materialsApplied = true
		texBtn.Text = "??  Текстура: " .. mat.Name .. " (вернуть)"
	end
end)

-- НЕВИДИМОСТЬ
local invisBtn = createButton("Невидимость", Color3.fromRGB(100, 100, 100), "??")
invisBtn.Parent = buttonContainer

local invisEnabled = false
local originalTransparencies = {}

local function toggleInvisible()
	character = player.Character or player.CharacterAdded:Wait()
	if invisEnabled then
		-- Вернуть видимость
		for part, trans in pairs(originalTransparencies) do
			if part and part.Parent then part.Transparency = trans end
		end
		originalTransparencies = {}
		invisEnabled = false
		invisBtn.Text = "??  Невидимость"
	else
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				originalTransparencies[part] = part.Transparency
				part.Transparency = 1
			elseif part:IsA("Decal") then
				originalTransparencies[part] = part.Transparency
				part.Transparency = 1
			end
		end
		local face = character:FindFirstChild("Head") and character.Head:FindFirstChildOfClass("Decal")
		if face then face.Transparency = 1 end
		invisEnabled = true
		invisBtn.Text = "??  Невидимость ВКЛ"
	end
end

invisBtn.MouseButton1Click:Connect(toggleInvisible)

-- БОЛЬШАЯ ГОЛОВА
local bigHeadBtn = createButton("Большая голова", Color3.fromRGB(255, 200, 0), "??")
bigHeadBtn.Parent = buttonContainer

local bigHeadEnabled = false
local originalHeadSize = nil

local function toggleBigHead()
	character = player.Character or player.CharacterAdded:Wait()
	local head = character:FindFirstChild("Head")
	if not head then return end

	if bigHeadEnabled then
		if originalHeadSize then head.Size = originalHeadSize end
		bigHeadEnabled = false
		bigHeadBtn.Text = "??  Большая голова"
	else
		originalHeadSize = head.Size
		head.Size = Vector3.new(4, 4, 4)
		bigHeadEnabled = true
		bigHeadBtn.Text = "??  Большая голова ВКЛ"
	end
end

bigHeadBtn.MouseButton1Click:Connect(toggleBigHead)

-- ===================== ЗВУКИ =====================
local section4 = createSectionLabel("-- ЗВУКИ --")
section4.Parent = buttonContainer

local sndBtn = createButton("Воспроизвести звук", Color3.fromRGB(0, 180, 80), "??")
sndBtn.Parent = buttonContainer

local soundList = {
	{ id = 139310882854462, name = "Scary Glitch V2" },
	{ id = 140028279221307, name = "Scary Scream" },
	{ id = 139836635302855, name = "Screaming Chicken" },
	{ id = 139918501762915, name = "Noise Angry Scream" },
}
local soundIndex = 0
local currentSound = nil

sndBtn.MouseButton1Click:Connect(function()
	if currentSound and currentSound.IsPlaying then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
		sndBtn.Text = "??  Воспроизвести звук"
		return
	end

	soundIndex = soundIndex % #soundList + 1
	local s = soundList[soundIndex]

	currentSound = Instance.new("Sound")
	currentSound.SoundId = "rbxassetid://" .. s.id
	currentSound.Volume = 0.7
	currentSound.Parent = workspace
	currentSound:Play()
	currentSound.Ended:Connect(function()
		if currentSound then
			currentSound:Destroy()
			currentSound = nil
			sndBtn.Text = "??  Воспроизвести звук"
		end
	end)

	sndBtn.Text = "??  " .. s.name .. " (стоп)"
end)

-- ===================== УТИЛИТЫ =====================
local section5 = createSectionLabel("-- УТИЛИТЫ --")
section5.Parent = buttonContainer

-- ANTI-AFK
local afkBtn = createButton("Anti-AFK", Color3.fromRGB(80, 80, 200), "??")
afkBtn.Parent = buttonContainer

local antiAfkEnabled = false
local antiAfkConnection = nil

local function toggleAntiAFK()
	if antiAfkEnabled then
		if antiAfkConnection then antiAfkConnection:Disconnect(); antiAfkConnection = nil end
		antiAfkEnabled = false
		afkBtn.Text = "??  Anti-AFK"
	else
		antiAfkConnection = player.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
		antiAfkEnabled = true
		afkBtn.Text = "??  Anti-AFK ВКЛ"
	end
end

afkBtn.MouseButton1Click:Connect(toggleAntiAFK)

-- REJOIN
local rejoinBtn = createButton("Перезайти на сервер", Color3.fromRGB(150, 50, 150), "??")
rejoinBtn.Parent = buttonContainer

rejoinBtn.MouseButton1Click:Connect(function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

-- SERVER HOP
local hopBtn = createButton("Найти другой сервер", Color3.fromRGB(50, 150, 150), "??")
hopBtn.Parent = buttonContainer

hopBtn.MouseButton1Click:Connect(function()
	local success, result = pcall(function()
		return HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
	end)
	if success and result then
		local data = HttpService:JSONDecode(result)
		local servers = data and data.data
		if servers then
			for _, server in ipairs(servers) do
				if server.id ~= game.JobId and server.playing < server.maxPlayers then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
					return
				end
			end
		end
	end
end)

-- RESET CHARACTER
local resetBtn = createButton("Убить персонажа", Color3.fromRGB(100, 0, 0), "??")
resetBtn.Parent = buttonContainer

resetBtn.MouseButton1Click:Connect(function()
	character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.Health = 0 end
end)

-- ===================== ПЕРЕТАСКИВАНИЕ ПАНЕЛИ =====================
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- ===================== ГОРЯЧАЯ КЛАВИША =====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

-- ===================== ОЧИСТКА ПРИ РЕСПАВНЕ =====================
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	-- Сбросить все состояния
	if flying then toggleFly() end
	if noclipEnabled then toggleNoclip() end
	if infJumpEnabled then toggleInfJump() end
	if spinEnabled then toggleSpin() end
	if godEnabled then toggleGod() end
	if invisEnabled then
		invisEnabled = false
		invisBtn.Text = "??  Невидимость"
	end
	if bigHeadEnabled then
		bigHeadEnabled = false
		bigHeadBtn.Text = "??  Большая голова"
	end
	if speedBoosted then
		speedBoosted = false
		speedBtn.Text = "?  Скорость x3"
	end
end)