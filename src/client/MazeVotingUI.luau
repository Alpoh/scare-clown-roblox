local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MazeVotingUI = {}

local MAZES = {
	{ id = "Maze1_Spiral", name = "DESIERTO", color = Color3.fromRGB(184, 134, 11) },
	{ id = "Maze2_Winding", name = "SÓTANO", color = Color3.fromRGB(105, 105, 105) },
	{ id = "Maze3_Grid", name = "MINA", color = Color3.fromRGB(64, 64, 64) },
}

local function makeButton(maze, index, buttonHolder, voteRemote, selectedMazeRef)
	local btn = Instance.new("TextButton")
	btn.Name = maze.id
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = maze.color
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.Bangers
	btn.Text = maze.name
	btn.TextScaled = true
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.LayoutOrder = index
	btn.Parent = buttonHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(200, 30, 30)
	stroke.Parent = btn

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = btn

	local function updateSelection()
		if selectedMazeRef.current == maze.id then
			TweenService:Create(scale, TweenInfo.new(0.1), { Scale = 1.1 }):Play()
			stroke.Color = Color3.fromRGB(255, 255, 0)
			stroke.Thickness = 5
		else
			TweenService:Create(scale, TweenInfo.new(0.1), { Scale = 1 }):Play()
			stroke.Color = Color3.fromRGB(200, 30, 30)
			stroke.Thickness = 3
		end
	end

	btn.MouseButton1Click:Connect(function()
		selectedMazeRef.current = maze.id
		for _, child in pairs(buttonHolder:GetChildren()) do
			if child:IsA("TextButton") then
				updateSelection()
			end
		end
		voteRemote:InvokeServer(maze.id)
	end)

	return btn
end

function MazeVotingUI.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MazeVoting"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 8

	local root = Instance.new("CanvasGroup")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 0
	root.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.new(0.5, 0, 0.1, 0)
	title.Size = UDim2.new(0.8, 0, 0.08, 0)
	title.BackgroundTransparency = 1
	title.Text = "ELIGE EL LABERINTO"
	title.Font = Enum.Font.Bangers
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(240, 195, 45)
	title.Parent = root

	local buttonHolder = Instance.new("Frame")
	buttonHolder.Name = "ButtonHolder"
	buttonHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	buttonHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
	buttonHolder.Size = UDim2.new(0.9, 0, 0.6, 0)
	buttonHolder.BackgroundTransparency = 1
	buttonHolder.Parent = root

	local layout = Instance.new("UIGridLayout")
	layout.CellPadding = UDim2.new(0, 20, 0, 20)
	layout.CellSize = UDim2.new(0.3, 0, 0.8, 0)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = buttonHolder

	local voteRemote = ReplicatedStorage:WaitForChild("VoteForMaze")
	local clownAssignedRemote = ReplicatedStorage:WaitForChild("ClownAssigned")
	local selectedMaze = { current = nil }

	for index, maze in pairs(MAZES) do
		makeButton(maze, index, buttonHolder, voteRemote, selectedMaze)
	end

	screenGui.Parent = playerGui

	clownAssignedRemote.OnClientEvent:Connect(function(clownPlayer)
		if clownPlayer == player then
			TweenService:Create(root, TweenInfo.new(0.3), { GroupTransparency = 1 }):Play()
			for _, child in pairs(buttonHolder:GetChildren()) do
				if child:IsA("TextButton") then
					child.Active = false
				end
			end
		else
			TweenService:Create(root, TweenInfo.new(0.3), { GroupTransparency = 0 }):Play()
		end
	end)
end

return MazeVotingUI
