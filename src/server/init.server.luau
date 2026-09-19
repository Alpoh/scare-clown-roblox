local RoundManager = require(script.RoundManager)
local RoleManager = require(script.RoleManager)
local SpawnManager = require(script.SpawnManager)
local CatchManager = require(script.CatchManager)

RoleManager.init(RoundManager)
SpawnManager.init(RoundManager, RoleManager)
CatchManager.init(RoundManager, RoleManager)
RoundManager.init()
