local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameVersion = require(ReplicatedStorage.Shared.GameVersion)
local AudioController = require(script.Parent.AudioController)
local UISlider = require(script.Parent.UISlider)

local function formatPercent(label, value)
	return string.format("%s %d%%", label, math.floor(value * 100 + 0.5))
end

local MainMenu = {}

function MainMenu.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local existing = playerGui:FindFirstChild("MainMenu")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainMenu"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 10

	local root = Instance.new("CanvasGroup")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 0
	root.Parent = screenGui

	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(15, 8, 8)
	bg.BorderSizePixel = 0
	bg.Parent = root

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 10, 10)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 6, 8)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 3, 4)),
	})
	bgGradient.Rotation = 65
	bgGradient.Parent = bg

	local stripeHolder = Instance.new("Frame")
	stripeHolder.Name = "Stripes"
	stripeHolder.Size = UDim2.fromScale(1, 1)
	stripeHolder.BackgroundTransparency = 1
	stripeHolder.ClipsDescendants = true
	stripeHolder.Parent = bg

	local stripeCount = 14
	for i = 1, stripeCount do
		local stripe = Instance.new("Frame")
		stripe.Name = "Stripe" .. i
		stripe.AnchorPoint = Vector2.new(0.5, 0.5)
		stripe.Size = UDim2.new(0.1, 0, 2.4, 0)
		stripe.Position = UDim2.new((i - 1) / (stripeCount - 1), 0, 0.5, 0)
		stripe.Rotation = 18
		stripe.BorderSizePixel = 0
		stripe.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(130, 15, 15) or Color3.fromRGB(0, 0, 0)
		stripe.BackgroundTransparency = 0.87
		stripe.Parent = stripeHolder
	end

	local titleShadow = Instance.new("TextLabel")
	titleShadow.Name = "TitleShadow"
	titleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	titleShadow.Position = UDim2.new(0.5, 5, 0.22, 5)
	titleShadow.Size = UDim2.new(0.9, 0, 0.16, 0)
	titleShadow.BackgroundTransparency = 1
	titleShadow.Text = "SCARECLOWN"
	titleShadow.Font = Enum.Font.Bangers
	titleShadow.TextScaled = true
	titleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
	titleShadow.TextTransparency = 0.15
	titleShadow.Rotation = -2
	titleShadow.Parent = root

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.new(0.5, 0, 0.22, 0)
	title.Size = UDim2.new(0.9, 0, 0.16, 0)
	title.BackgroundTransparency = 1
	title.Text = "SCARECLOWN"
	title.Font = Enum.Font.Bangers
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(240, 195, 45)
	title.TextStrokeColor3 = Color3.fromRGB(120, 5, 10)
	title.TextStrokeTransparency = 0
	title.Rotation = -2
	title.Parent = root

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subtitle.Position = UDim2.new(0.5, 0, 0.32, 0)
	subtitle.Size = UDim2.new(0.7, 0, 0.05, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "el circo nunca cierra..."
	subtitle.Font = Enum.Font.Creepster
	subtitle.TextScaled = true
	subtitle.TextColor3 = Color3.fromRGB(180, 60, 60)
	subtitle.TextTransparency = 0.1
	subtitle.Parent = root

	local buttonHolder = Instance.new("Frame")
	buttonHolder.Name = "ButtonHolder"
	buttonHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	buttonHolder.Position = UDim2.new(0.5, 0, 0.66, 0)
	buttonHolder.Size = UDim2.new(0.28, 0, 0.32, 0)
	buttonHolder.BackgroundTransparency = 1
	buttonHolder.Parent = root

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 18)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = buttonHolder

	local function makeButton(name, text, order, big, parent)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = big and UDim2.new(1, 0, 0.42, 0) or UDim2.new(0.72, 0, 0.3, 0)
		btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.Bangers
		btn.Text = text
		btn.TextScaled = true
		btn.TextColor3 = Color3.fromRGB(235, 225, 210)
		btn.LayoutOrder = order
		btn.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 3
		stroke.Color = Color3.fromRGB(200, 30, 30)
		stroke.Parent = btn

		local strokeGradient = Instance.new("UIGradient")
		strokeGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 190, 40)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 20, 20)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 190, 40)),
		})
		strokeGradient.Parent = stroke

		local scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = btn

		return btn
	end

	local playButton = makeButton("PlayButton", "JUGAR", 1, true, buttonHolder)
	local settingsButton = makeButton("SettingsButton", "AJUSTES", 2, false, buttonHolder)

	local dimmer = Instance.new("TextButton")
	dimmer.Name = "Dimmer"
	dimmer.Size = UDim2.fromScale(1, 1)
	dimmer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dimmer.BackgroundTransparency = 0.4
	dimmer.AutoButtonColor = false
	dimmer.Text = ""
	dimmer.Visible = false
	dimmer.ZIndex = 5
	dimmer.Parent = root

	local settingsPanel = Instance.new("Frame")
	settingsPanel.Name = "SettingsPanel"
	settingsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	settingsPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	settingsPanel.Size = UDim2.new(0.36, 0, 0.42, 0)
	settingsPanel.BackgroundColor3 = Color3.fromRGB(12, 8, 8)
	settingsPanel.Visible = false
	settingsPanel.Active = true
	settingsPanel.ZIndex = 6
	settingsPanel.Parent = root

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 14)
	panelCorner.Parent = settingsPanel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Thickness = 3
	panelStroke.Color = Color3.fromRGB(180, 20, 20)
	panelStroke.Parent = settingsPanel

	local panelTitle = Instance.new("TextLabel")
	panelTitle.Name = "PanelTitle"
	panelTitle.Size = UDim2.new(1, 0, 0.14, 0)
	panelTitle.Position = UDim2.new(0, 0, 0.04, 0)
	panelTitle.BackgroundTransparency = 1
	panelTitle.Text = "AJUSTES"
	panelTitle.Font = Enum.Font.Bangers
	panelTitle.TextScaled = true
	panelTitle.TextColor3 = Color3.fromRGB(240, 195, 45)
	panelTitle.ZIndex = 6
	panelTitle.Parent = settingsPanel

	local function makePanelButton(name, text, posY)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0.7, 0, 0.18, 0)
		btn.Position = UDim2.new(0.15, 0, posY, 0)
		btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		btn.AutoButtonColor = false
		btn.Text = text
		btn.Font = Enum.Font.Bangers
		btn.TextScaled = true
		btn.TextColor3 = Color3.fromRGB(230, 225, 210)
		btn.ZIndex = 6
		btn.Parent = settingsPanel

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(180, 20, 20)
		stroke.Parent = btn

		local scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = btn

		return btn
	end

	local function makePanelLabel(name, posY)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Size = UDim2.new(0.8, 0, 0.08, 0)
		label.Position = UDim2.new(0.1, 0, posY, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Bangers
		label.TextScaled = true
		label.TextColor3 = Color3.fromRGB(230, 225, 210)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 6
		label.Parent = settingsPanel
		return label
	end

	local musicLabel = makePanelLabel("MusicLabel", 0.20)
	local musicSlider = UISlider.create(settingsPanel, {
		name = "Music",
		position = UDim2.new(0.1, 0, 0.30, 0),
		size = UDim2.new(0.8, 0, 0, 10),
		initial = AudioController.getMusicVolume(),
		zIndex = 6,
		onChanged = function(value)
			AudioController.setMusicVolume(value)
			musicLabel.Text = formatPercent("VOLUMEN", value)
		end,
	})
	musicLabel.Text = formatPercent("VOLUMEN", musicSlider.getValue())

	local closeButton = makePanelButton("CloseButton", "CERRAR", 0.62)

	local versionLabel = Instance.new("TextLabel")
	versionLabel.Name = "VersionLabel"
	versionLabel.AnchorPoint = Vector2.new(1, 1)
	versionLabel.Position = UDim2.new(1, -12, 1, -8)
	versionLabel.Size = UDim2.new(0.12, 0, 0.03, 0)
	versionLabel.BackgroundTransparency = 1
	versionLabel.Font = Enum.Font.SourceSans
	versionLabel.TextScaled = true
	versionLabel.TextXAlignment = Enum.TextXAlignment.Right
	versionLabel.TextColor3 = Color3.fromRGB(180, 170, 165)
	versionLabel.TextTransparency = 0.35
	versionLabel.Text = "v" .. GameVersion
	versionLabel.Parent = root

	screenGui.Parent = playerGui

	local menuOpen = true
	local lockedHumanoid, savedWalkSpeed, savedJumpPower, savedJumpHeight

	local function lockCharacter(character)
		local humanoid = character:WaitForChild("Humanoid")
		lockedHumanoid = humanoid
		savedWalkSpeed = humanoid.WalkSpeed
		savedJumpPower = humanoid.JumpPower
		savedJumpHeight = humanoid.JumpHeight
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
	end

	local function unlockCharacter()
		if lockedHumanoid and lockedHumanoid.Parent then
			lockedHumanoid.WalkSpeed = savedWalkSpeed or 16
			lockedHumanoid.JumpPower = savedJumpPower or 50
			lockedHumanoid.JumpHeight = savedJumpHeight or 7.2
		end
		lockedHumanoid = nil
	end

	if player.Character then
		lockCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		if menuOpen then
			lockCharacter(character)
		end
	end)

	task.spawn(function()
		while title.Parent do
			task.wait(math.random(20, 60) / 10)
			if not title.Parent then
				break
			end
			TweenService:Create(title, TweenInfo.new(0.05), { TextTransparency = 0.6 }):Play()
			task.wait(0.05)
			if title.Parent then
				TweenService:Create(title, TweenInfo.new(0.08), { TextTransparency = 0 }):Play()
			end
		end
	end)

	local function setupHover(btn)
		local scale = btn:FindFirstChildOfClass("UIScale")
		if not scale then
			return
		end
		btn.MouseEnter:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Scale = 1.06 }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Scale = 1 }):Play()
		end)
	end

	for _, btn in ipairs({ playButton, settingsButton, closeButton }) do
		setupHover(btn)
	end

	local function openSettings()
		dimmer.Visible = true
		settingsPanel.Visible = true
	end

	local function closeSettings()
		dimmer.Visible = false
		settingsPanel.Visible = false
	end

	settingsButton.MouseButton1Click:Connect(openSettings)
	closeButton.MouseButton1Click:Connect(closeSettings)
	dimmer.MouseButton1Click:Connect(closeSettings)

	playButton.MouseButton1Click:Connect(function()
		closeSettings()
		menuOpen = false
		local fadeOut = TweenService:Create(root, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
		fadeOut:Play()
		fadeOut.Completed:Wait()
		screenGui.Enabled = false
		unlockCharacter()
	end)
end

return MainMenu
