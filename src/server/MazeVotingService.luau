local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MazeVotingService = {}

local MAZES = {
	{ id = "Maze1_Spiral", name = "Desierto", color = Color3.fromRGB(184, 134, 11) },
	{ id = "Maze2_Winding", name = "Sótano", color = Color3.fromRGB(105, 105, 105) },
	{ id = "Maze3_Grid", name = "Mina", color = Color3.fromRGB(64, 64, 64) },
}

local votes = {}
local selectedMaze = nil

local function resetVotes()
	votes = {
		[MAZES[1].id] = 0,
		[MAZES[2].id] = 0,
		[MAZES[3].id] = 0,
	}
	selectedMaze = nil
end

local function getWinningMaze()
	local maxVotes = 0
	local winner = MAZES[1].id

	for mazeId, voteCount in pairs(votes) do
		if voteCount > maxVotes then
			maxVotes = voteCount
			winner = mazeId
		end
	end

	selectedMaze = winner
	return winner
end

local function hideMazes(exceptMazeId)
	local Map = game.Workspace.Map
	for _, maze in pairs(MAZES) do
		local mazeFolder = Map:FindFirstChild(maze.id)
		if mazeFolder then
			local visible = (maze.id == exceptMazeId)
			for _, child in pairs(mazeFolder:GetChildren()) do
				child.Transparency = visible and 0 or 1
				child.CanCollide = visible
			end
		end

		local floorName = string.sub(maze.id, 1, 5) .. "_Floor"
		local floor = Map:FindFirstChild(floorName)
		if floor then
			floor.Transparency = visible and 0 or 1
			floor.CanCollide = visible
		end
	end

	local lobbyWalls = {
		"LobbyWallNorth",
		"LobbyWallSouth",
		"LobbyWallEast",
		"LobbyWallWest",
		"LobbyGate",
		"LobbyFloor"
	}
	for _, wallName in ipairs(lobbyWalls) do
		local wall = Map:FindFirstChild(wallName)
		if wall then
			wall.Transparency = 0
			wall.CanCollide = true
		end
	end
end

function MazeVotingService.init()
	resetVotes()

	local voteRemote = Instance.new("RemoteFunction")
	voteRemote.Name = "VoteForMaze"
	voteRemote.Parent = ReplicatedStorage

	function voteRemote.OnServerInvoke(player, mazeId)
		if votes[mazeId] ~= nil then
			votes[mazeId] = votes[mazeId] + 1
			return true
		end
		return false
	end
end

function MazeVotingService.tallyVotes()
	local winningMaze = getWinningMaze()
	hideMazes(winningMaze)
	return winningMaze
end

function MazeVotingService.getMazes()
	return MAZES
end

function MazeVotingService.resetForNewRound()
	resetVotes()
end

return MazeVotingService
