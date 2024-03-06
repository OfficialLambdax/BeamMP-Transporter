--Transporter by Julianstap, 2023

local M = {}
-- M.COBALT_VERSION = "1.7.6"
-- utils.setLogType("CTF",93)

local floor = math.floor
local mod = math.fmod
local rand = math.random

local gameState = {players = {}}
local vehicleIDs = {} --need this to couple vehid on spawn to player. gameState.players needs to be reset 
local vehVel = {}
local laststate = gameState
local levelName = ""
local area = ""
local areaNames = {}
local levels = {}
local requestedArea = ""
local flagPrefabCount = 1
local goalPrefabCount = 1
local timeSinceLastContact = 0
local requestedScoreLimit = 0
local teamSize = 1
local possibleTeams = {"Red", "LightBlue", "Green", "Yellow", "Purple"}
local chosenTeams = {}
local lastCollision = {"", ""}
local autoStartTimer = 0
local autoStart = false
local ghosts = true

gameState.flagExists = false
gameState.gameRunning = false
gameState.gameEnding = false
gameState.currentArea = ""
gameState.flagCount = 1
gameState.goalCount = 1
gameState.allowFlagCarrierResets = false

local roundLength = 5*60 -- length of the game in seconds
local defaultRedFadeDistance = 100 -- the distance between a flag carrier and someone that doesn't have the flag, where the screen of the flag carrier will turn red
local defaultColorPulse = true -- if the car color should pulse between the car color and blue
local defaultFlagTint = true -- if the infecor should have a blue tint
local defaultDistancecolor = 0.3 -- max intensity of the red filter
local teams = false

-- local TransporterCommands = {
-- 	transporter = {originModule = "Transporter", level = 0, arguments = {"argument"}, sourceLimited = 1, description = "Enables the .zip with the filename specified."},
-- 	ctf = {originModule = "Transporter", level = 0, arguments = {"argument"}, sourceLimited = 1, description = "Alias for transporter."},
-- 	CTF = {originModule = "Transporter", level = 0, arguments = {"argument"}, sourceLimited = 1, description = "Alias for transporter."}
-- }

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function seconds_to_days_hours_minutes_seconds(total_seconds) --modified code from https://stackoverflow.com/questions/45364628/lua-4-script-to-convert-seconds-elapsed-to-days-hours-minutes-seconds
    local time_days     = floor(total_seconds / 86400)
    local time_hours    = floor(mod(total_seconds, 86400) / 3600)
    local time_minutes  = floor(mod(total_seconds, 3600) / 60)
    local time_seconds  = floor(mod(total_seconds, 60))

	if time_days == 0 then
		time_days = nil
	end
    if time_hours == 0 then
        time_hours = nil
    end
	if time_minutes == 0 then
		time_minutes = nil
	end
	if time_seconds == 0 then
		time_seconds = nil
	end
    return time_days ,time_hours , time_minutes , time_seconds
end

function gameStarting()
	local days, hours , minutes , seconds = seconds_to_days_hours_minutes_seconds(roundLength)
	local amount = 0
	if days then
		amount = amount + 1
	end
	if hours then
		amount = amount + 1
	end
	if minutes then
		amount = amount + 1
	end
	if seconds then
		amount = amount + 1
	end
	if days then
		amount = amount - 1
		if days == 1 then
			if amount > 1 then
				days = ""..days.." day, "
			elseif amount == 1 then
				days = ""..days.." day and "
			elseif amount == 0 then
				days = ""..days.." day "
			end
		else
			if amount > 1 then
				days = ""..days.." days, "
			elseif amount == 1 then
				days = ""..days.." days and "
			elseif amount == 0 then
				days = ""..days.." days "
			end
		end
	end
	if hours then
		amount = amount - 1
		if hours == 1 then
			if amount > 1 then
				hours = ""..hours.." hour, "
			elseif amount == 1 then
				hours = ""..hours.." hour and "
			elseif amount == 0 then
				hours = ""..hours.." hour "
			end
		else
			if amount > 1 then
				hours = ""..hours.." hours, "
			elseif amount == 1 then
				hours = ""..hours.." hours and "
			elseif amount == 0 then
				hours = ""..hours.." hours "
			end
		end
	end
	if minutes then
		amount = amount - 1
		if minutes == 1 then
			if amount > 1 then
				minutes = ""..minutes.." minute, "
			elseif amount == 1 then
				minutes = ""..minutes.." minute and "
			elseif amount == 0 then
				minutes = ""..minutes.." minute "
			end
		else
			if amount > 1 then
				minutes = ""..minutes.." minutes, "
			elseif amount == 1 then
				minutes = ""..minutes.." minutes and "
			elseif amount == 0 then
				minutes = ""..minutes.." minutes "
			end
		end
	end
	if seconds then
		if seconds == 1 then
			seconds = ""..seconds.." second "
		else
			seconds = ""..seconds.." seconds "
		end
	end

	MP.SendChatMessage(-1,"Transporter game started, you have to survive for "..(days or "")..""..(hours or "")..""..(minutes or "")..""..(seconds or "").."")
end

function compareTable(gameState,tempTable,laststate)
	for variableName,variable in pairs(gameState) do
		if type(variable) == "table" then
			if not laststate[variableName] then
				laststate[variableName] = {}
			end
			if not tempTable[variableName] then
				tempTable[variableName] = {}
			end
			compareTable(gameState[variableName],tempTable[variableName],laststate[variableName])
			if type(tempTable[variableName]) == "table" and next(tempTable[variableName]) == nil then
				tempTable[variableName] = nil
			end
		elseif variable == "remove" then
			tempTable[variableName] = gameState[variableName]
			laststate[variableName] = nil
			gameState[variableName] = nil
		elseif laststate[variableName] ~= variable then
			tempTable[variableName] = gameState[variableName]
			laststate[variableName] = gameState[variableName]
		end
	end
end

function updateClients()
	local tempTable = {}
	compareTable(gameState,tempTable,laststate)
	-- print("updateClients: " .. dump(tempTable))

	if tempTable and next(tempTable) ~= nil then
		MP.TriggerClientEventJson(-1, "updateTransporterGameState", tempTable)
	end
end

function spawnFlag()
	local flagID = 0
	if flagPrefabCount > 0 then
		rand() --Some implementation need this before the numbers become random
		rand()
		rand()
		flagID = rand(1,flagPrefabCount)
	end
	print("Chosen flag: levels/" .. levelName .. "/multiplayer/" .. area .. "/flag" .. flagID .. ".prefab.json")
	MP.TriggerClientEvent(-1, "spawnFlag", "levels/" .. levelName .. "/multiplayer/" .. area .. "/flag" .. flagID .. ".prefab.json") --flagPrefabTable[rand(1, flagPrefabTable.size())]
end

function spawnGoal()
	local goalID = 0
	if goalPrefabCount > 0 then
		rand() --Some implementation need this before the numbers become random
		rand()
		rand()
		goalID = rand(1,goalPrefabCount)
	end
	print("Chosen goal: levels/" .. levelName .. "/multiplayer/" .. area .. "/goal" .. goalID .. ".prefab.json")
	MP.TriggerClientEvent(-1, "spawnGoal", "levels/" .. levelName .. "/multiplayer/" .. area .. "/goal" .. goalID .. ".prefab.json") --flagPrefabTable[rand(1, flagPrefabTable.size())]
end

function spawnFlagAndGoal()
	spawnFlag()
	spawnGoal()
end

function applyStuff(targetDatabase, tables)
	local appliedTables = {}
	for tableName, table in pairs(tables) do
		if targetDatabase[tableName]:exists() == false then
			for key, value in pairs(table) do
				targetDatabase[tableName][key] = value
			end
			appliedTables[tableName] = tableName
		end
	end
	return appliedTables
end

function setLevelName(playerID, name)
	levelName = name
	print("level name: " .. levelName)
end

function onAreaChange()	
	local foundArea = false
	for key,areaName in pairs(areaNames) do
		if areaName == requestedArea then
			area = areaName
			foundArea = true
		end
	end
	if area == "" or not foundArea then
		if areaNames[1] then
			area = areaNames[1]
			-- MP.SendChatMessage(-1, "The requested area for the transporter gamemode was not on this map, so it will default to the area " .. area)
			print("The requested area for the transporter gamemode was not on this map, so it will default to the area " .. area)
		else
			MP.SendChatMessage(-1, "Could not find an area to play on, on the map " .. levelName)
		end
	end
	MP.TriggerClientEvent(-1, "setCurrentArea", area)
	MP.TriggerClientEvent(-1, "requestFlagCount", "nil")
	MP.TriggerClientEvent(-1, "requestGoalCount", "nil")
end

function teamAlreadyChosen(team)
	return chosenTeams[team].chosen
end

function gameSetup()
	MP.TriggerClientEvent(-1, "requestVehicleID", "nil")
	local levelAvailable = false
	for i, level in pairs(levels) do
		if level == levelName then levelAvailable = true end
	end
	if not levelAvailable then 
		MP.SendChatMessage(-1, "Transporter is not available on this map.")
		return 
	end
	math.randomseed(os.time())
	onAreaChange()
	for k,v in pairs(possibleTeams) do
		chosenTeams[v] = {}
		chosenTeams[v].chosen = false
		chosenTeams[v].score = 0  
	end
	gameState = {}
	gameState.players = {}
	gameState.settings = {
		redFadeDistance = defaultRedFadeDistance,
		ColorPulse = defaultColorPulse,
		flagTint = defaultFlagTint,
		distancecolor = defaultDistancecolor
		}
	local playerCount = 0
	for ID,Player in pairs(MP.GetPlayers()) do
		if MP.IsPlayerConnected(ID) and MP.GetPlayerVehicles(ID) then
			playerCount = playerCount + 1
		end
	end
	if playerCount % 2 == 0 then
		teamSize = playerCount / 2
	elseif playerCount % 3 == 0 then
		teamSize = playerCount / 3
	else
		teamSize = 1
	end
	local chosenTeam = possibleTeams[rand(1,#possibleTeams)]
	local teamCount = 0
	for ID,Player in pairs(MP.GetPlayers()) do
		if teamCount == teamSize then
			chosenTeam = possibleTeams[rand(1,#possibleTeams)]
			while teamAlreadyChosen(chosenTeam) do --possibility for endless loop, maybe need some better way for this
				chosenTeam = possibleTeams[rand(1,#possibleTeams)]
			end
			chosenTeams[chosenTeam].chosen = true
			teamCount = 0
		end
		if MP.IsPlayerConnected(ID) and MP.GetPlayerVehicles(ID) then
			local player = {}
			player.ID = ID
			player.localContact = false
			player.remoteContact = false
			player.hasFlag = false
			player.score = 0
			player.team = chosenTeam
			-- player.allowedResets = true
			-- player.resetTimer = 3
			-- player.resetTimerActive = false
			player.fadeEndTime = 0
			player.fade = false
			gameState.players[Player] = player
			teamCount = teamCount + 1
		end
	end

	if playerCount == 0 then
		MP.SendChatMessage(-1,"Failed to start, found no vehicles")
		return
	end

	gameState.playerCount = playerCount
	gameState.time = 0
	gameState.roundLength = roundLength
	gameState.endtime = -1
	gameState.gameRunning = true
	gameState.gameEnding = false
	gameState.gameEnded = false
	gameState.teams = teams
	gameState.currentArea = ""
	gameState.flagCount = 1
	gameState.goalCount = 1
	gameState.scoreLimit = requestedScoreLimit

	spawnFlagAndGoal()
	MP.TriggerClientEvent(-1, "spawnObstacles", "levels/" .. levelName .. "/multiplayer/" .. area .. "/obstacles.prefab.json")

	updateClients()

	MP.TriggerClientEventJson(-1, "receiveTransporterGameState", gameState)
end

function transporterGameEnd(reason)
    MP.TriggerClientEvent(-1, "removePrefabs", "all")
	gameState.gameEnding = true
	if reason == nil or reason == "nil" then
		MP.SendChatMessage(-1,"Game stopped for uknown reason")
	else
		if reason == "time" then
			MP.SendChatMessage(-1,"Game over, time limit was reached")
		elseif reason == "manual" then
			MP.SendChatMessage(-1,"Game stopped, Everyone Looses")
			gameState.endtime = gameState.time + 10
		elseif reason == "score" then
			MP.SendChatMessage(-1,"Game over, score limit was reached")
			gameState.endtime = gameState.time + 10
		end
	end

	MP.SendChatMessage(-1,"The scores this round are: ")
	local highestScore = 0
	local winningTeam = ""
	if teams and chosenTeams then
		for teamName, teamData in pairs(chosenTeams) do
			if chosenTeams[teamName].chosen then
				-- print(dump(chosenTeams))
				chosenTeams[teamName].score = 0
				for playername,player in pairs(gameState.players) do
					if teamName == player.team then
						chosenTeams[teamName].score = chosenTeams[teamName].score + player.score
					end
				end
				if chosenTeams[teamName].score > highestScore then
					highestScore = chosenTeams[teamName].score
					winningTeam = teamName
				end
				MP.SendChatMessage(-1, "" .. teamName .. ": " .. chosenTeams[teamName].score)
			end
		end
	else
		for playername,player in pairs(gameState.players) do
			if player.score > highestScore then
				highestScore = player.score
			end
			MP.SendChatMessage(-1, "" .. playername .. ": " .. player.score)
		end
	end
	if teams and chosenTeams then
		MP.SendChatMessage(-1, "Team " .. winningTeam .. " Won!")
		for playername,player in pairs(gameState.players) do
			if player.team == winningTeam then
				MP.TriggerClientEvent(player.ID, "onWin", "nil")
			else
				MP.TriggerClientEvent(player.ID, "onLose", "nil")
			end
		end
	else
		for playername,player in pairs(gameState.players) do
			if player.score == highestScore then
				MP.SendChatMessage(-1, "" .. playername .. " Won!")
				print("" .. dump(player))
				MP.TriggerClientEvent(player.ID, "onWin", "nil")
			else
				MP.TriggerClientEvent(player.ID, "onLose", "nil")
			end
		end
	end

	if ghosts then
		for playerName,player in pairs(gameState.players) do
			gameState.players[playerName].fade = false
			-- print("Triggering unfadePerson " .. vehicleIDs[playerName].vehID)
			MP.TriggerClientEvent(-1, "unfadePerson", vehicleIDs[playerName].vehID)
		end	
	end
end

function showPrefabs(player) --shows the prefabs belonging to this map and this area
	MP.TriggerClientEvent(player.playerID, "spawnObstacles", "levels/" .. levelName .. "/multiplayer/" .. area .. "/obstacles.prefab.json") 
	for flagID=1,flagPrefabCount do
		MP.TriggerClientEvent(player.playerID, "spawnFlag", "levels/" .. levelName .. "/multiplayer/" .. area .. "/flag" .. flagID .. ".prefab.json") 
	end
	for goalID=1,goalPrefabCount do
		MP.TriggerClientEvent(player.playerID, "spawnGoal", "levels/" .. levelName .. "/multiplayer/" .. area .. "/goal" .. goalID .. ".prefab.json")
	end
end

function createFlag(player)
	MP.TriggerClientEvent(player.playerID, "onCreateFlag", "nil")
end

function createGoal(player)
	MP.TriggerClientEvent(player.playerID, "onCreateGoal", "nil")
end

function transporter(player, argument)
	if argument == "help" then
		MP.SendChatMessage(player.playerID, "Anything between double qoutes; \"\" is a command. \n Anything between single quotes; \'\' is an argument, \n if there is a slash it means those are the argument options for that command.")
		MP.SendChatMessage(player.playerID, "\"/transporter start\" to start a transporter game.")
		MP.SendChatMessage(player.playerID, "\"/transporter stop\" to stop a transporter game.")
		MP.SendChatMessage(player.playerID, "\"/transporter area \'chosenArea\' \" to choose an area to play transporter on.")
		MP.SendChatMessage(player.playerID, "\"/transporter list \'areas/levels\' \" to list the possible areas or levels to play transporter on.")
		MP.SendChatMessage(player.playerID, "\"/transporter show\" to show all flags and goals in the current area.")
		MP.SendChatMessage(player.playerID, "\"/transporter hide\" to hide all flags and goals in the current area.")
		MP.SendChatMessage(player.playerID, "\"/transporter start \'minutes\' \" to start a transporter game with a duration of the specified minutes.")
		MP.SendChatMessage(player.playerID, "\"/transporter time limit \'minutes\' \" to set the duration of a transporter game to the specified minutes.")
		MP.SendChatMessage(player.playerID, "\"/transporter score limit \'points\' \" to set the score limit of a transporter game to the specified score.")
		MP.SendChatMessage(player.playerID, "\"/transporter teams \'true/false\' \" to specify if the transporter games uses teams.")
		MP.SendChatMessage(player.playerID, "\"/transporter allow resets \'true/false\' \" to specify if the flag carrier can reset without losing the flag.")
		MP.SendChatMessage(player.playerID, "\"/transporter create \'flag/goal\' \" to create a goal or flag, so you can make your own areas! \n Consult the tutorial on GitHub to learn how to do this.")
		MP.SendChatMessage(player.playerID, "\"/transporter ghosts \'true/false\' \" to specify if people should be ghosts on reset and when getting the flag.")
	elseif argument == "show" then
		onAreaChange()
		showPrefabs(player)
	elseif argument == "hide" then
		MP.TriggerClientEvent(player.playerID, "removePrefabs", "all")
	elseif argument == "start" or string.find(argument, "start %d") then
		local number = 5
		if string.find(argument, "start %d") then
			number = tonumber(string.sub(argument,7,10000))
			roundLength = number * 60
			print("Transporter game starting with duration: " .. number)
		end
		if not gameState.gameRunning then
			if gameState.scoreLimit and gameState.scoreLimit > 0 then
				MP.SendChatMessage(-1, "Bring home " .. gameState.scoreLimit .. " to win!")
			end
			gameSetup()
			MP.SendChatMessage(-1, "Transporter started, GO GO GO!")
		else
			MP.SendChatMessage(-1, "A transporter game has already started.")
		end
	elseif string.find(argument, "time limit %d") then
		local number = tonumber(string.sub(argument,11,10000))
		roundLength = number * 60
		print("Transporter game time limit is now: " .. roundLength)
	elseif string.find(argument, "score limit %d") then
		local number = tonumber(string.sub(argument,12,10000))
		requestedScoreLimit = number
		print("Transporter game score limit is now: " .. number)
	elseif string.find(argument, "teams %S") then
		local teamsString = string.sub(argument,7,10000)
		if teamsString == "true" then
			teams = true
		elseif teamsString == "false" then
			teams = false
		end
		MP.SendChatMessage(-1, "Playing with teams: " .. dump(teams) .. " (available options are true or false)")
	elseif string.find(argument, "allow resets %S") then
		local allowedString = string.sub(argument,14,10000)
		if allowedString == "true" then
			gameState.allowFlagCarrierResets = true
		elseif allowedString == "false" then
			gameState.allowFlagCarrierResets = false
		end
		MP.SendChatMessage(-1, "Resets allowed when carrying flag: " .. dump(gameState.allowFlagCarrierResets) .. " (available options are true or false)")
	elseif string.find(argument, "ghosts %S") then
		local allowedString = string.sub(argument,8,10000)
		if allowedString == "true" then
			ghosts = true
		elseif allowedString == "false" then
			ghosts = false
		end
		MP.SendChatMessage(-1, "Resets allowed when carrying flag: " .. dump(gameState.allowFlagCarrierResets) .. " (available options are true or false)")
	elseif string.find(argument, "create %S") then
		local createString = string.sub(argument,8,10000) 
		if createString == "flag" then
			createFlag(player)
		elseif createString == "goal" then
			createGoal(player)
		end
	elseif string.find(argument, "list %S") then
		local subArgument = string.sub(argument,6,10000)
		if subArgument == "areas" then
			if areaNames == {} then
				MP.SendChatMessage(player.playerID, "There are no areas made for this map, a server restart might fix it or try a different map.")
			else
				MP.SendChatMessage(player.playerID, "Possible areas to play on this map: " .. dump(areaNames))
			end
		elseif subArgument == "levels" then
			if levels == {} then
				MP.SendChatMessage(player.playerID, "There are no levels available for transporter, obviously something is very wrong.")
			else
				MP.SendChatMessage(player.playerID, "Possible levels to play transporter on: " .. dump(levels))
			end
		else
			MP.SendChatMessage(player.playerID, "I can't " .. argument .. ", try something else (like list areas or list levels).")
		end
	elseif string.find(argument, "area %S") then
		requestedArea = string.sub(argument,6,10000)
		onAreaChange()
		MP.SendChatMessage(-1, "Requested area: " .. requestedArea)
	elseif argument == "stop" then
		transporterGameEnd("manual")
		MP.SendChatMessage(-1, "Transporter stopping...")
	end	
end

function ctf(player, argument) --alias for transporter
	transporter(player, argument)
end

function CTF(player, argument) --alias for transporter
	transporter(player, argument)
end

function gameRunningLoop()
	if gameState.time < 0 then
		MP.SendChatMessage(-1,"Transporter game starting in "..math.abs(gameState.time).." second")

	elseif gameState.time == 0 then
		gameStarting()
	end
	MP.TriggerClientEvent(-1, "requestVelocity", "nil")

	if not gameState.gameEnding and gameState.playerCount == 0 then
		gameState.gameEnding = true
		gameState.endtime = gameState.time + 2
	end

	local players = gameState.players

	if not gameState.gameEnding and gameState.time > 0 then
		local playercount = 0
		for playername,player in pairs(players) do
			if player.localContact and player.remoteContact then
				MP.SendChatMessage(-1,""..playername.." has captured the flag!")
			end		
			if ghosts and player.fade and gameState.time >= player.fadeEndTime then
				gameState.players[MP.GetPlayerName(player.ID)].fade = false
				-- print("Triggering unfadePerson " .. vehicleIDs[MP.GetPlayerName(player.ID)].vehID)
				MP.TriggerClientEvent(-1, "unfadePerson", vehicleIDs[MP.GetPlayerName(player.ID)].vehID)
			end
			if ghosts and not player.hasFlag and vehVel[MP.GetPlayerName(player.ID)] and (vehVel[MP.GetPlayerName(player.ID)].vel < 10) then --less than 10 km/h 
				gameState.players[MP.GetPlayerName(player.ID)].fade = true
				MP.TriggerClientEvent(-1, "fadePerson", vehicleIDs[MP.GetPlayerName(player.ID)].vehID)
				gameState.players[MP.GetPlayerName(player.ID)].fadeEndTime = gameState.time + 2
				-- print("A player should have faded cuz he slow af")
			end
			playercount = playercount + 1
		end
		gameState.playerCount = playercount

		if gameState.time >= 5 and transporterCount == 0 then

		end
	end

	if not gameState.gameEnding and gameState.time == gameState.roundLength then
		transporterGameEnd("time")
		gameState.endtime = gameState.time + 10
	elseif gameState.gameEnding and gameState.time == gameState.endtime then
		gameState.gameRunning = false
		gameState = {}
		gameState.players = {}
		gameState.gameRunning = false
		gameState.gameEnding = false
		gameState.gameEnded = true
		MP.TriggerClientEvent(-1, "onGameEnd", "nil")
		if ghosts then
			for playerName,player in pairs(gameState.players) do
				gameState.players[playerName].fade = false
				-- print("Triggering unfadePerson " .. vehicleIDs[playerName].vehID)
				MP.TriggerClientEvent(-1, "unfadePerson", vehicleIDs[playerName].vehID)
			end	
		end
	elseif not gameState.gameEnding and gameState.scoreLimit and gameState.scoreLimit ~= 0 then
		for playerName,player in pairs(gameState.players) do
			if player.score >= gameState.scoreLimit then
				transporterGameEnd("score")
				MP.SendChatMessage(-1, "Score limit was reached, " .. playerName .. " is the winner")
			end
		end
	end
	if gameState.gameRunning then
		timeSinceLastContact = timeSinceLastContact + 1
		gameState.time = gameState.time + 1
	else
		for playername,player in pairs(players) do
			if ghosts then
				-- gameState.players[MP.GetPlayerName(player.ID)].fade = false
				print("Triggering unfadePerson " .. vehicleIDs[MP.GetPlayerName(player.ID)].vehID)
				MP.TriggerClientEvent(-1, "unfadePerson", vehicleIDs[MP.GetPlayerName(player.ID)].vehID)
			end
		end
	end

	updateClients()
end

--resets flagcarrier and spawns a new flag
function resetFlagCarrier(localPlayerID, player) 
	-- print("resetFlagCarrier: " .. dump(player) .. " " .. localPlayerID)
	player = Util.JsonDecode(player)
	-- print("resetFlagCarrier: " .. dump(player) .. " Gamestate: " .. dump(gameState))
	if gameState.gameRunning and not gameState.gameEnding then
		if player.hasFlag == true then
			gameState.players[MP.GetPlayerName(localPlayerID)].hasFlag = false
			if not gameState.allowFlagCarrierResets then --whenever the flag switches places the previous flag carrier should be able to reset again
				MP.TriggerClientEvent(player.ID, "allowResets", "nil")
			end
			spawnFlag()
			MP.TriggerClientEvent(-1, "onFlagReset", "nil")
			print("Called onFlagReset")
			return
		end
	end
end

function transporterTimer()
	if gameState.gameRunning then
		gameRunningLoop()
	elseif autoStart and MP.GetPlayerCount() > -1 then
		autoStartTimer = autoStartTimer + 1
		if autoStartTimer >= 30 then
			autoStartTimer = 0
			gameSetup()
		end
	end
end

--called whenever the extension is loaded
function onInit()
    MP.RegisterEvent("requestTransporterGameState","requestTransporterGameState")
    MP.RegisterEvent("transporter","transporter")
    MP.RegisterEvent("ctf","ctf")
    MP.RegisterEvent("CTF","CTF")
    MP.TriggerClientEventJson(-1, "receiveTransporterGameState", gameState)
	
	MP.CancelEventTimer("counter")
	MP.CancelEventTimer("transporterSecond")
	MP.CreateEventTimer("transporterSecond",1000)
	MP.RegisterEvent("transporterSecond", "transporterTimer")

	MP.RegisterEvent("onTransporterContact", "onTransporterContact")
	MP.RegisterEvent("setLevelName", "setLevelName")
	MP.RegisterEvent("setFlagCarrier", "setFlagCarrier")
	MP.RegisterEvent("onGoal", "onGoal")
	MP.RegisterEvent("setAreaNames", "setAreaNames")
	MP.RegisterEvent("setLevels", "setLevels")
	MP.RegisterEvent("setFlagCount", "setFlagCount")
	MP.RegisterEvent("setGoalCount", "setGoalCount")
	MP.RegisterEvent("resetFlagCarrier", "resetFlagCarrier")
	MP.RegisterEvent("onTransporterContactreceive","onTransporterContact")
	MP.RegisterEvent("setVehicleID","setVehicleID")
	MP.RegisterEvent("setVehVel","setVehVel")
	MP.RegisterEvent("onChatMessage","onChatMessage")
	
	MP.RegisterEvent("onPlayerFirstAuth","onPlayerFirstAuth")
	MP.RegisterEvent("onPlayerAuth","onPlayerAuth")
	MP.RegisterEvent("onPlayerConnecting","onPlayerConnecting")
	MP.RegisterEvent("onPlayerJoining","onPlayerJoining")
	MP.RegisterEvent("onPlayerJoin","onPlayerJoin")
	MP.RegisterEvent("onPlayerDisconnect","onPlayerDisconnect")
	MP.RegisterEvent("onVehicleSpawn","onVehicleSpawn")
	MP.RegisterEvent("onVehicleEdited","onVehicleEdited")
	MP.RegisterEvent("onVehicleReset","onVehicleReset")
	MP.RegisterEvent("onVehicleDeleted","onVehicleDeleted")

	-- applyStuff(commands, TransporterCommands)
	print("--------------------Transporter loaded----------------")
end


function onUnload()

end

--called whenever a player is authenticated by the server for the first time.
function onPlayerFirstAuth(player)

end

--called whenever the player is authenticated by the server.
function onPlayerAuth(player)

end

--called whenever someone begins connecting to the server
function onPlayerConnecting(player)
	MP.TriggerClientEventJson(player.playerID, "receiveTransporterGameState", gameState)
end

--called when a player begins loading
function onPlayerJoining(player)

end

--called whenever a player has fully joined the session
function onPlayerJoin(player)
	MP.TriggerClientEvent(-1, "requestLevelName", "nil") --TODO: fix this when changing levels somehow
	MP.TriggerClientEvent(-1, "requestAreaNames", "nil")
	MP.TriggerClientEvent(-1, "requestLevels", "nil")
end

--called whenever a player disconnects from the server
function onPlayerDisconnect(player)
	gameState.players[player.name] = nil
	vehicleIDs[player.name] = nil
end

--called whenever a player sends a chat message
function onChatMessage(player_id, player_name, chatMessage)
	local player = {}
	player.playerID = player_id
	-- print("onChatMessage( " .. dump(player) .. ", " .. chatMessage .. ")")
	if string.find(chatMessage, "/ctf") then
		chatMessage = string.gsub(chatMessage, "/ctf ", "")
		transporter(player, chatMessage)
	end
	if string.find(chatMessage, "/CTF") then
		chatMessage = string.gsub(chatMessage, "/CTF ", "")
		transporter(player, chatMessage)
	end
	if string.find(chatMessage, "/transporter") then
		chatMessage = string.gsub(chatMessage, "/transporter ", "")
		transporter(player, chatMessage)
	end
end

--called whenever a player spawns a vehicle.
function onVehicleSpawn(player, vehID,  data)

end

--called whenever a player applies their vehicle edits.
function onVehicleEdited(player, vehID,  data)

end

--called whenever a player resets their vehicle, holding insert spams this function.
function onVehicleReset(player, vehID, data)
	if not gameState or not player or not gameState.players or not gameState.gameRunning or not gameState.players[player.name] or gameState.allowFlagCarrierResets then return end
	resetFlagCarrier(nil, Util.JsonEncode(gameState.players[player.name]))
	if ghosts then
		MP.TriggerClientEvent(-1, "fadePerson", "" .. vehicleIDs[MP.GetPlayerName(player.playerID)].vehID)
		gameState.players[MP.GetPlayerName(player.playerID)].fade = true
		gameState.players[MP.GetPlayerName(player.playerID)].fadeEndTime = gameState.time + 2
	end
end

--called whenever a vehicle is deleted
function onVehicleDeleted(player, vehID,  source)

end

--whenever a message is sent to the Rcon
function onRconCommand(player, message, password, prefix)

end

--whenever a new client interacts with the RCON
function onNewRconClient(client)

end

--called when the server is stopped through the stopServer() function
function onStopServer()

end

function requestTransporterGameState(localPlayerID)
	if levelName == "" then MP.TriggerClientEvent(localPlayerID, "requestLevelName", "nil") end
	if areaNames == {} then MP.TriggerClientEvent(localPlayerID, "requestAreaNames", "nil") end
	if levels == {} then MP.TriggerClientEvent(localPlayerID, "requestLevels", "nil") end
	if area == "" then onAreaChange() end
	MP.TriggerClientEventJson(localPlayerID, "receiveTransporterGameState", gameState)
end

function onTransporterContact(localPlayerID, data)
	local remotePlayerName = MP.GetPlayerName(tonumber(data))
	local localPlayerName = MP.GetPlayerName(localPlayerID)
	if timeSinceLastContact < 0.5 or (timeSinceLastContact <= 1.5 and ((lastCollision[1] == remotePlayerName and lastCollision[2] == localPlayerName) or (lastCollision[1] == localPlayerName and lastCollision[2] == remotePlayerName))) then return end
	lastCollision[1] = localPlayerName
	lastCollision[2] = remotePlayerName
	if gameState.gameRunning and not gameState.gameEnding then
		local localPlayer = gameState.players[localPlayerName]
		local remotePlayer = gameState.players[remotePlayerName]
		if localPlayer and remotePlayer then
			if gameState.teams then
				if localPlayer.team == remotePlayer.team then return end
			end
			local remotePlayerID = tonumber(data)
			if localPlayer.hasFlag == true and remotePlayer.hasFlag == false then
				gameState.players[localPlayerName].hasFlag = false
				gameState.players[remotePlayerName].hasFlag = true
				MP.TriggerClientEvent(localPlayerID, "allowResets", "nil") --lost flag
				MP.TriggerClientEvent(localPlayerID, "onLostFlag", "nil")
				MP.TriggerClientEvent(remotePlayerID, "disallowResets", "nil") --got flag
				MP.TriggerClientEvent(remotePlayerID, "onGotFlag", "nil")
				if ghosts then
					MP.TriggerClientEvent(-1, "fadePerson", "" .. vehicleIDs[remotePlayerName].vehID)
					gameState.players[remotePlayerName].fade = true
					gameState.players[remotePlayerName].fadeEndTime = gameState.time + 2
				end
				
				gameState.players[remotePlayerName].remoteContact = false
				MP.SendChatMessage(-1, "".. remotePlayerName .." has captured the flag!")
			elseif remotePlayer.hasFlag == true and localPlayer.hasFlag == false then
				gameState.players[localPlayerName].hasFlag = true
				gameState.players[remotePlayerName].hasFlag = false
				MP.TriggerClientEvent(localPlayerID, "disallowResets", "nil") --got flag
				MP.TriggerClientEvent(localPlayerID, "onGotFlag", "nil")
				MP.TriggerClientEvent(remotePlayerID, "allowResets", "nil") --lost flag
				MP.TriggerClientEvent(remotePlayerID, "onLostFlag", "nil")
				gameState.players[localPlayerName].localContact = false
				if ghosts then
					MP.TriggerClientEvent(-1, "fadePerson", "" .. vehicleIDs[localPlayerName].vehID)
					gameState.players[localPlayerName].fade = true
					gameState.players[localPlayerName].fadeEndTime = gameState.time + 2
				end
				MP.SendChatMessage(-1, "".. localPlayerName .." has captured the flag!")
			end
			timeSinceLastContact = 0
		end
	end
end

function setFlagCarrier(playerID)
	if gameState.players[MP.GetPlayerName(playerID)].hasFlag == false then 
		for playername,player in pairs(gameState.players) do
			gameState.players[playername].hasFlag = false
		end
		gameState.players[MP.GetPlayerName(playerID)].hasFlag = true
		MP.TriggerClientEvent(-1, "removePrefabs", "flag")
		-- print("" .. dump(gameState) .. " " .. vehicleIDs[MP.GetPlayerName(playerID)].vehID)
		-- if ghosts then --uncomment to enable ghost when going through the flag marker
		-- 	MP.TriggerClientEvent(-1, "fadePerson", "" .. vehicleIDs[MP.GetPlayerName(playerID)].vehID)
		-- 	gameState.players[MP.GetPlayerName(playerID)].fade = true
		-- 	gameState.players[MP.GetPlayerName(playerID)].fadeEndTime = gameState.time + 2
		-- end
		MP.SendChatMessage(-1,"".. MP.GetPlayerName(playerID) .." has the flag!")
	end
	updateClients()
end

function onGoal(playerID)
	if gameState.players[MP.GetPlayerName(playerID)].hasFlag == true then 
		gameState.players[MP.GetPlayerName(playerID)].score = gameState.players[MP.GetPlayerName(playerID)].score + 1
		gameState.players[MP.GetPlayerName(playerID)].hasFlag = false
		MP.TriggerClientEvent(-1, "removePrefabs", "goal")
		MP.TriggerClientEvent(playerID, "onScore", "nil")
		updateClients()
		MP.SendChatMessage(-1,"".. MP.GetPlayerName(playerID) .." Scored a point!")
		spawnFlagAndGoal()
	end
end

function setAreaNames(playerID, data)
	areaNames = {} 
	print("Available areas: " .. data)
	for name in data:gmatch("%S+") do 
		table.insert(areaNames, name)
	end
	onAreaChange()
end

function setVehVel(playerID, vel)
	vehVel[MP.GetPlayerName(playerID)] = {}
	vehVel[MP.GetPlayerName(playerID)].vel = tonumber(vel)
	-- print("Set the velocity: " .. vel)
end

function setLevels(playerID, data)
	levels = {}
	for name in data:gmatch("%S+") do 
		table.insert(levels, name) 
	end
end

function setFlagCount(playerID, data)
	flagPrefabCount = tonumber(data)
end

function setGoalCount(playerID, data)
	goalPrefabCount = tonumber(data)
end

function setVehicleID(playerID, vehID)
	-- print("setVehicleID " .. MP.GetPlayerName(playerID))
	vehicleIDs[MP.GetPlayerName(playerID)] = {}
	vehicleIDs[MP.GetPlayerName(playerID)].vehID = vehID
end

M.onInit = onInit
M.onUnload = onUnload

M.onPlayerFirstAuth = onPlayerFirstAuth

M.onPlayerAuth = onPlayerAuth
M.onPlayerConnecting = onPlayerConnecting
M.onPlayerJoining = onPlayerJoining
M.onPlayerJoin = onPlayerJoin
M.onPlayerDisconnect = onPlayerDisconnect

M.onChatMessage = onChatMessage

M.onVehicleSpawn = onVehicleSpawn
M.onVehicleEdited = onVehicleEdited
M.onVehicleReset = onVehicleReset
M.onVehicleDeleted = onVehicleDeleted

M.onRconCommand = onRconCommand
M.onNewRconClient = onNewRconClient

M.onStopServer = onStopServer

M.requestTransporterGameState = requestTransporterGameState

M.onTransporterContact = onTransporterContact

M.setFlagCarrier = setFlagCarrier
M.onGoal = onGoal
M.setAreaNames = setAreaNames
M.setLevels = setLevels
M.setFlagCount = setFlagCount
M.setGoalCount = setGoalCount
M.resetFlagCarrier = resetFlagCarrier

M.setLevelName = setLevelName
M.setVehicleID = setVehicleID
M.setVehVel = setVehVel

M.transporter = transporter
M.ctf = ctf
M.CTF = CTF

return M
