local M = {}

local floor = math.floor
local mod = math.fmod

local gamestate = {players = {}, settings = {}}

--blocked inputs when flag carrier
local blockedInputActions = {'slower_motion','faster_motion','toggle_slow_motion','modify_vehicle','vehicle_selector','saveHome','loadHome', 'reset_all_physics','toggleTraffic', "recover_vehicle", "recover_vehicle_alt", "recover_to_last_road", "reload_vehicle", "reload_all_vehicles", "parts_selector", "dropPlayerAtCamera", "nodegrabberRender",'reset_physics','switch_previous_vehicle','switch_next_vehicle'} --"dropPlayerAtCameraNoReset", missing. This allows for resets with f7, this should be done with a sort of timer on reset or only alow rewinds. This seems to not be possible

local colors = {["Red"] = {255,50,50,255},["LightBlue"] = {50,50,160,255},["Green"] = {50,255,50,255},["Yellow"] = {200,200,25,255},["Purple"] = {150,50,195,255}}
local thisAreaData = {}
local thisLevelData = {}
local mapData = {} --TODO: this should be a txt file for easily adding areas
mapData.levels = ""

--Industrial level data:
thisLevelData = {}
thisLevelData.name = "industrial"
thisLevelData.levelData = {}
thisLevelData.areas = ""

--dockyard area data:
thisAreaData = {}
thisAreaData.name = "Port"
thisAreaData.flagcount = "16"
thisAreaData.goalcount = "16"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData
mapData.levels = mapData.levels .. " " .. thisLevelData.name

--industry area data:
thisAreaData = {}
thisAreaData.name = "Industry"
thisAreaData.flagcount = "7"
thisAreaData.goalcount = "7"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData

--container land area data:
thisAreaData = {}
thisAreaData.name = "Containerland"
thisAreaData.flagcount = "6"
thisAreaData.goalcount = "6"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData

--Warehouses area data:
thisAreaData = {}
thisAreaData.name = "Warehouses"
thisAreaData.flagcount = "7"
thisAreaData.goalcount = "7"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData

--Battersea level data:
thisLevelData = {}
thisLevelData.name = "battersea"
thisLevelData.levelData = {}
thisLevelData.areas = ""

-- all area data:
thisAreaData = {}
thisAreaData.name = "All"
thisAreaData.flagcount = "32"
thisAreaData.goalcount = "32"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData

--depot area data:
thisAreaData = {}
thisAreaData.name = "Depot"
thisAreaData.flagcount = "9"
thisAreaData.goalcount = "9"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData
mapData.levels = mapData.levels .. " " .. thisLevelData.name

--Italy level data:
thisLevelData = {}
thisLevelData.name = "italy"
thisLevelData.levelData = {}
thisLevelData.areas = ""

-- Citta_Vecchia area data:
thisAreaData = {}
thisAreaData.name = "Citta_Vecchia"
thisAreaData.flagcount = "10"
thisAreaData.goalcount = "10"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData

-- Norte area data:
thisAreaData = {}
thisAreaData.name = "Norte"
thisAreaData.flagcount = "10"
thisAreaData.goalcount = "11"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData

-- Airport area data:
thisAreaData = {}
thisAreaData.name = "Airport"
thisAreaData.flagcount = "8"
thisAreaData.goalcount = "8"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData

-- Castelletto area data:
thisAreaData = {}
thisAreaData.name = "Castelletto"
thisAreaData.flagcount = "5"
thisAreaData.goalcount = "5"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData
mapData.levels = mapData.levels .. " " .. thisLevelData.name

--West Coast USA level data:
thisLevelData = {}
thisLevelData.name = "west_coast_usa"
thisLevelData.levelData = {}
thisLevelData.areas = ""

--City area data:
thisAreaData = {}
thisAreaData.name = "City"
thisAreaData.flagcount = "15"
thisAreaData.goalcount = "15"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData
mapData.levels = mapData.levels .. " " .. thisLevelData.name

--Island area data:
thisAreaData = {}
thisAreaData.name = "Island"
thisAreaData.flagcount = "11"
thisAreaData.goalcount = "11"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData
mapData.levels = mapData.levels .. " " .. thisLevelData.name

--Foundry area data:
thisAreaData = {}
thisAreaData.name = "Foundry"
thisAreaData.flagcount = "6"
thisAreaData.goalcount = "6"
thisLevelData.levelData[thisAreaData.name] = thisAreaData
thisLevelData.areas = thisLevelData.areas .. " " .. thisAreaData.name 
mapData[thisLevelData.name] = thisLevelData
mapData.levels = mapData.levels .. " " .. thisLevelData.name

local currentArea = ""
local currentLevel = ""
local lastCreatedFlagID = 1
local lastCreatedGoalID = 1

local defaultRedFadeDistance = 20

local flagPrefabActive = false
local flagPrefabPath
local flagPrefabName
local flagPrefabObj
local flagLocation = {}

local goalPrefabActive = false
local goalPrefabPath
local goalPrefabName
local goalPrefabObj
local goalLocation = {}

local obstaclesPrefabActive = false
local obstaclesPrefabPath
local obstaclesPrefabName
local obstaclesPrefabObj

local flagMarker = {}
flagMarker.x = 0
flagMarker.y = 0
flagMarker.arrowAngle = 0
flagMarker.showArrow = false
flagMarker.showHeightArrow = false
flagMarker.showIcon = false
flagMarker.abovePlayer = false

local goalMarker = {}
goalMarker.x = 140
goalMarker.y = 0
goalMarker.arrowAngle = 0
goalMarker.showArrow = false
goalMarker.showHeightArrow = false
goalMarker.showIcon = false
goalMarker.abovePlayer = false

local uiMessages = {}
uiMessages.showMSGYouScored = false
uiMessages.showMSGLostTheFlag = false
uiMessages.showMSGGotTheFlag = false
uiMessages.showMSGFlagReset = false
uiMessages.showMSGYouWin = false
uiMessages.showMSGYouLose = false
uiMessages.showMSGYouScoredEndTime = 0
uiMessages.showMSGLostTheFlagEndTime = 0
uiMessages.showMSGGotTheFlagEndTime = 0
uiMessages.showMSGFlagResetEndTime = 0
uiMessages.showMSGYouWinEndTime = 0
uiMessages.showMSGYouLoseEndTime = 0
uiMessages.showForTime = 2 --2s because the timing is inconsistent, maybe I should add a onSecond function or something

local screenWidth = GFXDevice.getDesktopMode().width
local screenHeight = GFXDevice.getDesktopMode().height
if screenHeight > 1080 then screenHeight = 1080 end --it seems ui apps are limited to 1080p
if screenWidth > 1920 then screenWidth = 1920 end

local logTag = "Transporter"

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

local function seconds_to_days_hours_minutes_seconds(total_seconds) --modified code from https://stackoverflow.com/questions/45364628/lua-4-script-to-convert-seconds-elapsed-to-days-hours-minutes-seconds
    local time_minutes  = floor(mod(total_seconds, 3600) / 60)
    local time_seconds  = floor(mod(total_seconds, 60))
    if (time_seconds < 10) and time_minutes > 0 then
        time_seconds = "0" .. time_seconds
    end
	if time_minutes > 0 then
    	return time_minutes .. ":" .. time_seconds
	else
    	return time_seconds
	end
end

local function distance(vec1, vec2)
	return math.sqrt((vec2.x-vec1.x)^2 + (vec2.y-vec1.y)^2 + (vec2.z-vec1.z)^2)
end

local function angle2D(vec1, vec2) --in degrees, because I thought it would be less conversions
	-- if vec1 == nil or vec2 == nil then return end
	local angle = math.atan2( vec1.y - vec2.y, vec2.x - vec1.x)
	return angle * (180 / math.pi)
end

function resetCarColors(data)
	if data then
		local vehicle = data
		if vehicle then
			if vehicle.originalColor then
				vehicle.color = vehicle.originalColor
			end
			if vehicle.originalcolorPalette0 then
				vehicle.colorPalette0 = vehicle.originalcolorPalette0
			end
			if vehicle.originalcolorPalette1 then
				vehicle.colorPalette1 = vehicle.originalcolorPalette1
			end
		end
	else
		for k,serverVehicle in pairs(MPVehicleGE.getVehicles()) do
			local ID = serverVehicle.gameVehicleID
			local vehicle = be:getObjectByID(ID)
			if vehicle then
				if serverVehicle.originalColor then
					vehicle.color = serverVehicle.originalColor
				end
				if serverVehicle.originalcolorPalette0 then
					vehicle.colorPalette0 = serverVehicle.originalcolorPalette0
				end
				if serverVehicle.originalcolorPalette1 then
					vehicle.colorPalette1 = serverVehicle.originalcolorPalette1
				end
			end
		end
	end
	scenetree["PostEffectCombinePassObject"]:setField("enableBlueShift", 0,0)
	scenetree["PostEffectCombinePassObject"]:setField("blueShiftColor", 0,"0 0 0")


	--core_input_actionFilter.addAction(0, 'vehicleTeleporting', false)
	--core_input_actionFilter.addAction(0, 'vehicleMenues', false)
	--core_input_actionFilter.addAction(0, 'freeCam', false)
	--core_input_actionFilter.addAction(0, 'resetPhysics', false)
end

local function receiveTransporterGameState(data)
	local data = jsonDecode(data)
	if not gamestate.gameRunning and data.gameRunning then
		for k,vehicle in pairs(MPVehicleGE.getVehicles()) do
			local ID = vehicle.gameVehicleID
			local veh = be:getObjectByID(ID)
			if veh then
				vehicle.originalColor = be:getObjectByID(ID).color
				vehicle.originalcolorPalette0 = be:getObjectByID(ID).colorPalette0
				vehicle.originalcolorPalette1 = be:getObjectByID(ID).colorPalette1
			end
		end
	end

	gamestate = data
	be:queueAllObjectLua("if Transporter then Transporter.setTransporterGameState("..serialize(gamestate)..") end")
end

function mergeTransporterTable(table,gamestateTable)
	if gamestateTable == nil then gamestateTable = {} end
	for variableName,value in pairs(table) do
		if type(value) == "table" then
			mergeTransporterTable(value,gamestateTable[variableName])
		elseif value == "remove" then
			gamestateTable[variableName] = nil
		else
			gamestateTable[variableName] = value
		end
	end
end

function allowResets()
	-- log('D', logtag, "allowResets called")
	if not gamestate.allowFlagCarrierResets then
		extensions.core_input_actionFilter.setGroup('CTF_Blocked_Inputs', blockedInputActions)
		extensions.core_input_actionFilter.addAction(0, 'CTF_Blocked_Inputs', false)
	end
end

function disallowResets()
	-- log('D', logtag, "disallowResets called")
	if not gamestate.allowFlagCarrierResets then --debating if this should stay here
		extensions.core_input_actionFilter.setGroup('CTF_Blocked_Inputs', blockedInputActions)
		extensions.core_input_actionFilter.addAction(0, 'CTF_Blocked_Inputs', true)
	else
		extensions.core_input_actionFilter.setGroup('CTF_Blocked_Inputs', blockedInputActions)
		extensions.core_input_actionFilter.addAction(0, 'CTF_Blocked_Inputs', false)
	end
end

local function spawnFlag(filepath, offset) 
	log('D', logTag, filepath)
	local offsetString = '0 0 0'
	if offset then
		offsetString = "" .. offset.x .. " " .. offset.y .. " " .. offset.z
	end
	log('D', logTag, "Offset: " .. offsetString)
	flagPrefabActive = true
	flagPrefabPath   = filepath
	flagPrefabName   = string.gsub(flagPrefabPath, "(.*/)(.*)", "%2"):sub(1, -13)
	flagPrefabObj    = spawnPrefab(flagPrefabName, flagPrefabPath, offsetString, '0 0 1', '1 1 1')
	log('D', logTag, "flagPrefabObj: " .. dump(flagPrefabObj))
	-- read local file 
	local file = io.open(flagPrefabPath, "rb")
	if not file then return end
	local jsonString = file:read "*a"
	file:close()
	log('D', logTag, "prefab json: " .. dump(jsonString))
	if jsonString then 
		local line = jsonDecode(jsonString)
		if line.name == "flagTrigger" then 
			flagLocation = vec3(line.position)
		end
	end
end

local function spawnGoal(filepath, offset) 
	log('D', logTag, filepath)
	local offsetString = '0 0 0'
	if offset then
		offsetString = "" .. offset.x .. " " .. offset.y .. " " .. offset.z
	end
	log('D', logTag, "Offset: " .. offsetString)
	goalPrefabActive = true
	goalPrefabPath   = filepath
	goalPrefabName   = string.gsub(goalPrefabPath, "(.*/)(.*)", "%2"):sub(1, -13)
	goalPrefabObj    = spawnPrefab(goalPrefabName, goalPrefabPath,  offsetString, '0 0 1', '1 1 1')
	log('D', logTag, "goalPrefabObj: " .. dump(goalPrefabObj))	
	-- read local file 
	local file = io.open(goalPrefabPath, "rb")
	if not file then return end
	local jsonString = file:read "*a"
	file:close()	
	log('D', logTag, "prefab json: " .. dump(jsonString))
	if jsonString then 
		local line = jsonDecode(jsonString)
		if line.name == "goalTrigger" then 
			goalLocation = vec3(line.position)
		end
	end
end

local function onCreateFlag()
	local currentVehID = be:getPlayerVehicleID(0)
	local veh = be:getObjectByID(currentVehID)
	if not veh then return end
	spawnFlag("levels/flag_.prefab.json", veh:getPosition())
end

local function onCreateGoal()
	local currentVehID = be:getPlayerVehicleID(0)
	local veh = be:getObjectByID(currentVehID)
	if not veh then return end
	spawnGoal("levels/goal_.prefab.json", veh:getPosition())
end

local function spawnObstacles(filepath) 
	log('D', logTag, filepath)
	obstaclesPrefabActive = true
	obstaclesPrefabPath   = filepath
	obstaclesPrefabName   = string.gsub(obstaclesPrefabPath, "(.*/)(.*)", "%2"):sub(1, -13)
	obstaclesPrefabObj    = spawnPrefab(obstaclesPrefabName, obstaclesPrefabPath, '0 0 0', '0 0 1', '1 1 1')
	be:reloadStaticCollision(true)
end

local function removePrefabs(type)
	log('D', logTag, "removePrefabs(" .. type .. ") Called" )
	if type == "flag" and flagPrefabActive then 
		removePrefab(flagPrefabName)
		-- log('D', logTag, "Removing: " .. flagPrefabName)
		flagPrefabActive = false
	elseif type == "goal" and goalPrefabActive then 
		removePrefab(goalPrefabName)
		-- log('D', logTag, "Removing: " .. goalPrefabName)
		goalPrefabActive = false
	elseif type == "all" then
		if flagPrefabActive then
			removePrefab(flagPrefabName)
			-- log('D', logTag, "Removing: " .. flagPrefabName)
			flagPrefabActive = false
		end
		if goalPrefabActive then
			removePrefab(goalPrefabName)
			-- log('D', logTag, "Removing: " .. goalPrefabName)
			goalPrefabActive = false
		end
		if obstaclesPrefabActive then
			removePrefab(obstaclesPrefabName)
			-- log('D', logTag, "Removing: " .. obstaclesPrefabName)
			obstaclesPrefabActive = false
			be:reloadStaticCollision(true)
		end
		local prefabPath = ""
		local levelName = core_levels.getLevelName(getMissionFilename())
		local flags = "1"
		local goals = "1"
		log('D', logTag, "Removing everything in; Map: " .. levelName .. " and Area: " .. currentArea)
		-- log('D', logTag, "mapData: " .. dump(mapData))
		local levelData = {}
		levelData = mapData[levelName]["levelData"]
		-- log('D', logTag, "levelData: " .. dump(levelData))
		local areaData = {}
		areaData = levelData[currentArea]
		-- log('D', logTag, "areaData (" .. currentArea .. "): " .. dump(areaData))
		flags = areaData["flagcount"]
		goals = areaData["goalcount"]
		log('D', logTag, "Flags: " .. flags .. " and Goals: " .. goals)
		for flagID=1,tonumber(flags) do
			prefabPath = "flag" .. flagID
			-- log('D', logTag, "Removing: " .. prefabPath)
			removePrefab(prefabPath)
		end
		for goalID=1,tonumber(goals) do
			prefabPath = "goal" .. goalID
			-- log('D', logTag, "Removing: " .. prefabPath)
			removePrefab(prefabPath)
		end
	end
end

function onGameEnd()
	core_gamestate.setGameState('multiplayer', 'multiplayer', 'multilpayer') --reset the app layout
	allowResets()
end

local function onLostFlag()
	uiMessages.showMSGLostTheFlag = true
	uiMessages.showMSGLostTheFlagEndTime = gamestate.time + uiMessages.showForTime
end

local function onGotFlag()
	uiMessages.showMSGGotTheFlag = true
	uiMessages.showMSGGotTheFlagEndTime = gamestate.time + uiMessages.showForTime
end

local function onFlagReset()
	uiMessages.showMSGFlagReset = true
	uiMessages.showMSGFlagResetEndTime = gamestate.time + uiMessages.showForTime
end

local function onScore()
	uiMessages.showMSGYouScored = true
	uiMessages.showMSGYouScoredEndTime = gamestate.time + uiMessages.showForTime
end

local function onWin()
	uiMessages.showMSGYouWin = true
	uiMessages.showMSGYouWinEndTime = gamestate.time + uiMessages.showForTime
	-- log('D', logtag, "onWin called")
end

local function onLose()
	uiMessages.showMSGYouLose = true
	uiMessages.showMSGYouLoseEndTime = gamestate.time + uiMessages.showForTime
	-- log('D', logtag, "onLose called" .. gamestate.time .. " " .. uiMessages.showMSGYouLoseEndTime)
end

local function dropPlayerAtCameraNoReset()
	--COPY OF GAMES SCRIPT FOR F7:
	local playerVehicle = be:getPlayerVehicle(0)
	if not playerVehicle then return end
	local pos = core_camera.getPosition()
	local camDir = core_camera.getForward()
	camDir.z = 0
	local camRot = quatFromDir(camDir, vec3(0,0,1))
	camRot = quat(0, 0, 1, 0) * camRot -- vehicles' forward is inverted
  
	local vehRot = quat(playerVehicle:getClusterRotationSlow(playerVehicle:getRefNodeId()))
	local diffRot = vehRot:inversed() * camRot
	playerVehicle:setClusterPosRelRot(playerVehicle:getRefNodeId(), pos.x, pos.y, pos.z, diffRot.x, diffRot.y, diffRot.z, diffRot.w)
	playerVehicle:applyClusterVelocityScaleAdd(playerVehicle:getRefNodeId(), 0, 0, 0, 0)
	core_camera.setGlobalCameraByName(nil) --this line has changed to avoid unknown function
	if core_camera.getActiveCamName(0) == "bigMap" then
	  core_camera.setByName(0, "orbit", false)
	end
	core_camera.resetCamera(0)
	playerVehicle:setOriginalTransform(pos.x, pos.y, pos.z, camRot.x, camRot.y, camRot.z, camRot.w)
	--Reset flag carrier on f7:
	local data = jsonEncode(gamestate.players[MPConfig.getNickname()])
	if TriggerServerEvent then TriggerServerEvent("resetFlagCarrier", data) end
	-- log('D', logtag, "dropPlayerAtCameraNoReset called " .. MPConfig.getNickname() .. " " .. dump(gamestate.players))
end

function onBeamNGTrigger(data)
	-- log('D', logtag, "trigger data: " .. dump(data))
    if data == "null" then return end
	-- if data.event ~= "enter" then return end
    local trigger = data.triggerName
    if MPVehicleGE.isOwn(data.subjectID) == true then
		if trigger == "flagTrigger" then
			if not gamestate.allowFlagCarrierResets then
				disallowResets()
			else
				allowResets()
			end
			onGotFlag()
			if TriggerServerEvent then TriggerServerEvent("setFlagCarrier", "nil") end
		elseif trigger == "goalTrigger" then	
			if not gamestate.players[MPVehicleGE.getNicknameMap()[data.subjectID]].fade then
				if not gamestate.allowFlagCarrierResets then
					allowResets()
				end
				if TriggerServerEvent then TriggerServerEvent("onGoal", "nil") end
			end
		end
    end
end

local function requestVehicleID()
	-- log('D', logtag, "" .. dump(MPVehicleGE.getVehicleMap()) .. " " .. be:getPlayerVehicleID(0))
	if not MPVehicleGE.getServerVehicleID(be:getPlayerVehicleID(0)) then return end
	if TriggerServerEvent then TriggerServerEvent("setVehicleID", "" ..  MPVehicleGE.getServerVehicleID(be:getPlayerVehicleID(0))) end
end

local function fadePerson(vehID)
	local alpha = 128
	if MPVehicleGE.getGameVehicleID(vehID) == -1 then return end
	vehicle =  be:getObjectByID(MPVehicleGE.getGameVehicleID(vehID))
	vehicle:queueLuaCommand("obj:setGhostEnabled(true)")
	vehicle:setMeshAlpha(alpha,"",false)
end

local function unfadePerson(vehID)
	if MPVehicleGE.getGameVehicleID(vehID) == -1 then return end
	vehicle =  be:getObjectByID(MPVehicleGE.getGameVehicleID(vehID))
	vehicle:queueLuaCommand("obj:setGhostEnabled(false)")
	vehicle:setMeshAlpha(1,"")
end

local function requestLevelName()
  currentLevel = core_levels.getLevelName(getMissionFilename())
  if TriggerServerEvent then TriggerServerEvent("setLevelName", currentLevel) end
end

function setCurrentArea(area)
	currentArea = area
end

local function requestAreaNames()
	local levelName = core_levels.getLevelName(getMissionFilename())
	if TriggerServerEvent and mapData[levelName] then TriggerServerEvent("setAreaNames", mapData[levelName].areas) end
end

local function requestLevels()
	if TriggerServerEvent then TriggerServerEvent("setLevels", mapData.levels) end
end

local function requestFlagCount()
	local levelName = core_levels.getLevelName(getMissionFilename())	
	local flags = "1"
	log('D', logTag, "mapData: " .. dump(mapData))
	local levelData = {}
	levelData = mapData[levelName]["levelData"]
	log('D', logTag, "levelData: " .. dump(levelData))
	local areaData = {}
	areaData = levelData[currentArea]
	log('D', logTag, "areaData: " .. dump(areaData))
	flags = areaData["flagcount"]
	log('D', logTag, "There are " .. flags .. " flags in " .. levelName .. ", " .. currentArea)
	if TriggerServerEvent then TriggerServerEvent("setFlagCount", flags) end
end

local function requestGoalCount()
	local levelName = core_levels.getLevelName(getMissionFilename())	
	local goals = "1"
	log('D', logTag, "mapData: " .. dump(mapData))	
	local levelData = {}
	levelData = mapData[levelName]["levelData"]
	log('D', logTag, "levelData: " .. dump(levelData))
	local areaData = {}
	areaData = levelData[currentArea]
	log('D', logTag, "areaData (" .. currentArea .. "): " .. dump(areaData))
	goals = areaData["goalcount"]
	log('D', logTag, "There are " .. goals .. " goals in " .. levelName .. ", " .. currentArea)
	if TriggerServerEvent then TriggerServerEvent("setGoalCount", goals) end
end

function updateTransporterGameState(data)
	mergeTransporterTable(jsonDecode(data),gamestate)

	local time = 0

	if gamestate.time then time = gamestate.time-1 end
	-- for playerName, player in pairs(gamestate.players) do
	-- 	if player.resetTimerActive then
	-- 		if player.resetTimer > 0 then
	-- 			player.resetTimer = player.resetTimer - 1
	-- 		else
	-- 			player.resetTimerActive = false
	-- 			extensions.core_input_actionFilter.setGroup('CTF_Blocked_Inputs', blockedInputActions)
	-- 			extensions.core_input_actionFilter.addAction(0, 'CTF_Blocked_Inputs', false)	
	-- 		end
	-- 	end
	-- end

	local txt = ""
	if time and time == 0 then
		core_gamestate.setGameState('transporter', 'transporter', 'transporter')
	end

	if time and time < 0 then
		txt = "Game starts in "..math.abs(time).." seconds"
	elseif gamestate.gameRunning and not gamestate.gameEnding and time or gamestate.endtime and (gamestate.endtime - time) > 9 then
		local timeLeft = seconds_to_days_hours_minutes_seconds(gamestate.roundLength - time)
		txt = "Transporter Time Left: ".. timeLeft --game is still going
	elseif time and gamestate.endtime and (gamestate.endtime - time) < 7 then
		local timeLeft = gamestate.endtime - time
		txt = "Transporter Colors reset in "..math.abs(timeLeft-1).." seconds" --game ended
	end
	if txt ~= "" then
		guihooks.message({txt = txt}, 1, "Transporter.time")
	end
	if uiMessages.showMSGFlagReset then
		if gamestate.time >= uiMessages.showMSGFlagResetEndTime then
		uiMessages.showMSGFlagReset = false
		uiMessages.showMSGFlagResetEndTime = 0
		end
	end
	if uiMessages.showMSGYouScored then
		if gamestate.time >= uiMessages.showMSGYouScoredEndTime then
		uiMessages.showMSGYouScored = false
		uiMessages.showMSGYouScoredEndTime = 0
		end
	end
	if uiMessages.showMSGGotTheFlag then
		if gamestate.time >= uiMessages.showMSGGotTheFlagEndTime then
		uiMessages.showMSGGotTheFlag = false
		uiMessages.showMSGGotTheFlagEndTime = 0
		end
	end
	if uiMessages.showMSGLostTheFlag then
		if gamestate.time >= uiMessages.showMSGLostTheFlagEndTime then
		uiMessages.showMSGLostTheFlag = false
		uiMessages.showMSGLostTheFlagEndTime = 0
		end
	end
	if uiMessages.showMSGYouWin then
		if time >= uiMessages.showMSGYouWinEndTime then
		uiMessages.showMSGYouWin = false
		uiMessages.showMSGYouWinEndTime = 0
		end
	end
	if uiMessages.showMSGYouLose then
		if time >= uiMessages.showMSGYouLoseEndTime then
		uiMessages.showMSGYouLose = false
		uiMessages.showMSGYouLoseEndTime = 0
		end
	end
	if gamestate.gameEnded then
		resetCarColors()
	end
end

local function requestTransporterGameState()
	if TriggerServerEvent then TriggerServerEvent("requestTransporterGameState","nil") end
end

local function sendTransporterContact(vehID,localVehID)
	log('D', logTag, "sendTransporterContact called")
	if not MPVehicleGE or MPCoreNetwork and not MPCoreNetwork.isMPSession() then return end
	local LocalvehPlayerName = MPVehicleGE.getNicknameMap()[localVehID]
	local vehPlayerName = MPVehicleGE.getNicknameMap()[vehID]
	log('D', logTag, "not MPVehicleGE or MPCoreNetwork and not MPCoreNetwork.isMPSession() ")
	log('D', logTag, "LocalvehPlayerName " .. LocalvehPlayerName .. " vehPlayerName " .. vehPlayerName .. " vehID " .. vehID ..  " localVehID " ..localVehID)
	local serverVehID = MPVehicleGE.getServerVehicleID(vehID)
	local remotePlayerID, vehicleID = string.match(serverVehID, "(%d+)-(%d+)")
	if TriggerServerEvent then TriggerServerEvent("onTransporterContact", remotePlayerID) end
end

local function onVehicleSwitched(oldID,ID)
	local currentOwnerName = MPConfig.getNickname()
	if ID and MPVehicleGE.getVehicleByGameID(ID) then
		currentOwnerName = MPVehicleGE.getVehicleByGameID(ID).ownerName
	end
end

local distancecolor = -1

function nametags(ownerName,player,vehicle) --draws flag nametags on people
	if player and player.hasFlag == true then
		local veh = be:getObjectByID(vehicle.gameVehicleID)
		if veh then
			local vehPos = veh:getPosition()
			local posOffset = vec3(0,0,2)
			debugDrawer:drawTextAdvanced(vehPos+posOffset, String("Flag"), ColorF(1,1,1,1), true, false, ColorI(50,50,200,255))
		end
	end
end

-- local function onVehicleResetted(gameVehicleID)
-- 	log('D', logtag, "OnVehicleResetted called")
-- 	if MPVehicleGE then
-- 		if MPVehicleGE.isOwn(gameVehicleID) then
-- 			local veh = be:getObjectByID(gameVehicleID)
-- 			if veh then
-- 				if not gamestate.players[veh.ownerName].allowedResets then
-- 					local txt = ""
-- 					txt = "You can reset in " .. gamestate.players[veh.ownerName].resetTimer .. "seconds"
-- 					gamestate.players[veh.ownerName].resetTimerActive = true
-- 					guihooks.message({txt = txt}, 1, "nil")
-- 				end
-- 			end
-- 		end
-- 	end
-- end

local function color(player,vehicle,team,dt)
	local teamColor
	if gamestate.teams and player.team then
		teamColor = colors[player.team]
	end
	if player.hasFlag == true then
		if not vehicle.transition or not vehicle.colortimer then
			vehicle.transition = 1
			vehicle.colortimer = 1.6
		end
		local veh = be:getObjectByID(vehicle.gameVehicleID)
		if veh then
			if not vehicle.originalColor then
				vehicle.originalColor = veh.color
			end
			if not vehicle.originalcolorPalette0 then
				vehicle.originalcolorPalette0 = veh.colorPalette0
			end
			if not vehicle.originalcolorPalette1 then
				vehicle.originalcolorPalette1 = veh.colorPalette1
			end

			if not gamestate.gameEnding or (gamestate.endtime - gamestate.time) > 1 then
				local transition = vehicle.transition
				local colortimer = vehicle.colortimer
				local color = 0.6 - (1*((1+math.sin(colortimer))/2)*0.2)
				local colorfade = (1*((1+math.sin(colortimer))/2))*math.max(0.6,transition)
				local bluefade = 1 -((1*((1+math.sin(colortimer))/2))*(math.max(0.6,transition)))
				local teamColorfade = 1 -((1*((1+math.sin(colortimer))/2))*(math.max(0.6,transition)))
				if gamestate.settings and not gamestate.settings.ColorPulse then
					color = 0.6
					colorfade = transition
					bluefade = 1 - transition
				end

				if teamColor then
					veh.color = ColorF((teamColor[1] * teamColorfade) / 255, (teamColor[2] * teamColorfade) / 255, (teamColor[3] * teamColorfade) / 255, vehicle.originalColor.w):asLinear4F()
					veh.colorPalette0 = ColorF((teamColor[1] * teamColorfade) / 255,(teamColor[2] * teamColorfade) / 255, (teamColor[3] * teamColorfade) / 255, vehicle.originalcolorPalette0.w):asLinear4F()
					veh.colorPalette1 = ColorF((teamColor[1] * teamColorfade) / 255,(teamColor[2] * teamColorfade) / 255, (teamColor[3] * teamColorfade) / 255, vehicle.originalcolorPalette1.w):asLinear4F()
				else
					veh.color = ColorF(vehicle.originalColor.x*colorfade, vehicle.originalColor.y*colorfade, (vehicle.originalColor.z*colorfade) + (color*bluefade), vehicle.originalColor.w):asLinear4F()
					veh.colorPalette0 = ColorF(vehicle.originalcolorPalette0.x*colorfade, vehicle.originalcolorPalette0.y*colorfade, (vehicle.originalcolorPalette0.z*colorfade) + (color*bluefade), vehicle.originalcolorPalette0.w):asLinear4F()
					veh.colorPalette1 = ColorF(vehicle.originalcolorPalette1.x*colorfade, vehicle.originalcolorPalette1.y*colorfade, (vehicle.originalcolorPalette1.z*colorfade) + (color*bluefade), vehicle.originalcolorPalette1.w):asLinear4F()
				end
				vehicle.colortimer = colortimer + (dt*2.6)
				if transition > 0 then
					vehicle.transition = math.max(0,transition - dt)
				end

				vehicle.color = color
				vehicle.colorfade = colorfade
				vehicle.bluefade = bluefade
			elseif (gamestate.endtime - gamestate.time) <= 1 then
				local transition = vehicle.transition
				local color = vehicle.color or 0
				local colorfade = vehicle.colorfade or 1
				local bluefade = vehicle.bluefade or 0
			
				veh.color = ColorF(vehicle.originalColor.x*colorfade, vehicle.originalColor.y*colorfade , (vehicle.originalColor.z*colorfade) + (color*bluefade), vehicle.originalColor.w):asLinear4F()
				veh.colorPalette0 = ColorF(vehicle.originalcolorPalette0.x*colorfade, vehicle.originalcolorPalette0.y*colorfade, (vehicle.originalcolorPalette0.z*colorfade) + (color*bluefade), vehicle.originalcolorPalette0.w):asLinear4F()
				veh.colorPalette1 = ColorF(vehicle.originalcolorPalette1.x*colorfade, vehicle.originalcolorPalette1.y*colorfade, (vehicle.originalcolorPalette1.z*colorfade) + (color*bluefade), vehicle.originalcolorPalette1.w):asLinear4F()
			
				vehicle.colorfade = math.min(1,colorfade + dt)
				vehicle.bluefade = math.max(0,bluefade - dt)
				vehicle.colortimer = 1.6
				if transition < 1 then
					vehicle.transition = math.min(1,transition + dt)
				end
			end
		end
	end
end

local function onPreRender(dt)
	if MPCoreNetwork and not MPCoreNetwork.isMPSession() then return end

	local currentVehID = be:getPlayerVehicleID(0)
	local currentOwnerName = MPConfig.getNickname()
	if currentVehID and MPVehicleGE.getVehicleByGameID(currentVehID) then
		currentOwnerName = MPVehicleGE.getVehicleByGameID(currentVehID).ownerName
	end

	if not gamestate.gameRunning or gamestate.gameEnding then 
		local veh = be:getObjectByID(currentVehID)
		if veh then
			local uiData = {}
			uiData.gameRunning = false or gamestate.gameEnding
			uiData.showFlagArrow = false
			uiData.showFlagIcon = false
			uiData.showFlagHeightArrow = false
			uiData.flagAbovePlayer = flagMarker.abovePlayer
			uiData.flagX = -140
			uiData.flagY = -140
			uiData.flagAngle = flagMarker.arrowAngle
			uiData.goalAbovePlayer = goalMarker.abovePlayer
			uiData.showGoalArrow = false
			uiData.showGoalHeightArrow = false
			uiData.showGoalIcon = false
			uiData.goalX = -140
			uiData.goalY = -140
			uiData.goalAngle = goalMarker.arrowAngle
			uiData.showMSGYouWin = uiMessages.showMSGYouWin	
			uiData.showMSGYouLose = uiMessages.showMSGYouLose		
			veh:queueLuaCommand('gui.send(\'Transporter\',' .. serialize(uiData) ..')')
		end
		return 
	end
	resetCarColors()
	-- log('D', logtag, "onPreRender called")

	local closestOpponent = 100000000

	for k,vehicle in pairs(MPVehicleGE.getVehicles()) do
		if gamestate.players then
			local player = gamestate.players[vehicle.ownerName]
			if player and currentOwnerName and vehicle then
				nametags(currentOwnerName,player,vehicle)
				if player.hasFlag then
					if core_camera.getForward() then
						local myVeh = be:getObjectByID(currentVehID)
						local veh = be:getObjectByID(vehicle.gameVehicleID)	
						if myVeh and veh then 
							local vehPos = myVeh:getPosition()
							local flagVehPos = veh:getPosition()	
							if flagVehPos.z > vehPos.z + 5 then 
								flagMarker.abovePlayer = true
								flagMarker.showHeightArrow = true 
							elseif flagVehPos.z < vehPos.z - 5 then
								flagMarker.abovePlayer = false
								flagMarker.showHeightArrow = true
							else
								flagMarker.showHeightArrow = false
							end
							local camVec = core_camera.getForward()
							local camPos = core_camera.getPosition()
							-- log('D', logtag, "camVec: " .. dump(camVec))
							local origin = vec3(0,0,0)
							local camRot = angle2D(camVec, origin)
							-- log('D', logtag, "vehRot: " .. dump(camRot))
							flagMarker.arrowAngle = angle2D(camPos, flagVehPos)
							flagMarker.arrowAngle = (flagMarker.arrowAngle - camRot) - 180 --apparently it is offset with 180 degrees for some reason
							flagMarker.showArrow = true
							flagMarker.showIcon = true
							flagMarker.x = (screenWidth / 2 - 140 / 2) + math.sqrt(((screenWidth/2) * (screenWidth/2)) + ((screenHeight/2) * (screenHeight/2))) * math.cos((flagMarker.arrowAngle - 90) * (math.pi / 180))
							flagMarker.y = (screenHeight / 2 - 140 / 2) + math.sqrt(((screenWidth/2) * (screenWidth/2)) + ((screenHeight/2) * (screenHeight/2))) * math.sin((flagMarker.arrowAngle - 90) * (math.pi / 180))
						end
					end
				end
				color(player,vehicle,gamestate.players[vehicle.ownerName].team,dt)
				if gamestate.players[currentOwnerName] and currentVehID and gamestate.players[currentOwnerName].hasFlag and not gamestate.players[vehicle.ownerName].hasFlag and currentVehID ~= vehicle.gameVehicleID then
					local myVeh = be:getObjectByID(currentVehID)
					local veh = be:getObjectByID(vehicle.gameVehicleID)				
					if veh and myVeh then
						if not gamestate.players[vehicle.ownerName].hasFlag and gamestate.players[vehicle.ownerName].team ~= gamestate.players[currentOwnernam] then
							local distance = distance(myVeh:getPosition(),veh:getPosition())
							if distance < closestOpponent then
								closestOpponent = distance
							end
						end
					end
				end
				if gamestate.teams then
					local veh = be:getObjectByID(vehicle.gameVehicleID)	
					local vehPos = veh:getPosition()
					local posOffset = vec3(0,0,1.5)
					debugDrawer:drawTextAdvanced(vehPos + posOffset, String("Team " .. gamestate.players[vehicle.ownerName].team), ColorF(1,1,1,1), true, false, ColorI(colors[gamestate.players[vehicle.ownerName].team][1], colors[gamestate.players[vehicle.ownerName].team][2], colors[gamestate.players[vehicle.ownerName].team][3], colors[gamestate.players[vehicle.ownerName].team][4]))
				end
			end
		end
	end
	
	if gamestate.players[currentOwnerName].hasFlag then
		flagMarker.showArrow = false
		flagMarker.showHeightArrow = false
		flagMarker.showIcon = false
	end

	if flagPrefabActive and flagLocation then
		local veh = be:getObjectByID(currentVehID)	
		if veh then
			local vehPos = veh:getPosition()
			if flagLocation.z + 2 > vehPos.z + 5 then --apparantly the prefablocation is 2 meters off
				flagMarker.abovePlayer = true
				flagMarker.showHeightArrow = true 
			elseif flagLocation.z + 2 < vehPos.z - 5 then
				flagMarker.abovePlayer = false
				flagMarker.showHeightArrow = true
			else
				flagMarker.showHeightArrow = false
			end
			if core_camera.getForward() then
				local camVec = core_camera.getForward()
				local camPos = core_camera.getPosition()
				-- log('D', logtag, "camVec: " .. dump(camVec))
				local origin = vec3(0,0,0)
				local camRot = angle2D(camVec, origin)
				-- log('D', logtag, "vehRot: " .. dump(camRot))
				flagMarker.arrowAngle = angle2D(camPos, flagLocation)
				flagMarker.arrowAngle = (flagMarker.arrowAngle - camRot) - 180 --apparently it is offset with 180 degrees for some reason
				flagMarker.showArrow = true
				flagMarker.showIcon = true
				flagMarker.x = (screenWidth / 2 - 140 / 2) + math.sqrt(((screenWidth/2) * (screenWidth/2)) + ((screenHeight/2) * (screenHeight/2))) * math.cos((flagMarker.arrowAngle - 90) * (math.pi / 180)) --TODO: make this work better on higher resolutions than 1080p
				flagMarker.y = (screenHeight / 2 - 140 / 2) + math.sqrt(((screenWidth/2) * (screenWidth/2)) + ((screenHeight/2) * (screenHeight/2))) * math.sin((flagMarker.arrowAngle - 90) * (math.pi / 180))
			end
			debugDrawer:drawTextAdvanced(flagLocation, String("Flag " .. round(distance(vehPos, flagLocation), 0) .. "m"), ColorF(1,1,1,1), true, false, ColorI(50,50,200,255))
		end
	end

	if goalPrefabActive and goalLocation then
		local veh = be:getObjectByID(currentVehID)	
		if veh then
			local vehPos = veh:getPosition()
			if goalLocation.z + 2 > vehPos.z + 5 then 
				goalMarker.abovePlayer = true
				goalMarker.showHeightArrow = true 
			elseif goalLocation.z + 2 < vehPos.z - 5 then
				goalMarker.abovePlayer = false
				goalMarker.showHeightArrow = true
			else
				goalMarker.showHeightArrow = false
			end
			if core_camera.getForward() then
				local camVec = core_camera.getForward()
				local camPos = core_camera.getPosition()
				-- log('D', logtag, "camVec: " .. dump(camVec))
				local origin = vec3(0,0,0)
				local camRot = angle2D(camVec, origin)
				-- log('D', logtag, "vehRot: " .. dump(camRot))
				goalMarker.arrowAngle = angle2D(camPos, goalLocation)
				-- goalMarker.arrowAngle = goalMarker.arrowAngle + camRot
				goalMarker.arrowAngle = (goalMarker.arrowAngle - camRot) - 180 --apparently it is offset with 180 degrees for some reason
				goalMarker.showIcon = true
				goalMarker.showArrow = true
				goalMarker.x = (screenWidth / 2 - 140 / 2) + math.sqrt(((screenWidth/2) * (screenWidth/2)) + ((screenHeight/2) * (screenHeight/2))) * math.cos((goalMarker.arrowAngle - 90) * (math.pi / 180)) --TODO: make this work better on higher resolutions than 1080p
				goalMarker.y = (screenHeight / 2 - 140 / 2) + math.sqrt(((screenWidth/2) * (screenWidth/2)) + ((screenHeight/2) * (screenHeight/2))) * math.sin((goalMarker.arrowAngle - 90) * (math.pi / 180))
			end
			debugDrawer:drawTextAdvanced(goalLocation, String("Goal " .. round(distance(vehPos, goalLocation), 0)) .. "m", ColorF(1,1,1,1), true, false, ColorI(50,200,50,255))
		end
	-- else --no goal but should only be for a real small amount of time
	-- 	goalMarker.showIcon = false
	-- 	goalMarker.showHeightArrow = false
	-- 	goalMarker.showArrow = false
	-- 	-- goalMarker.x = -140
	-- 	-- goalMarker.y = -140
	end
	local tempSetting = defaultRedFadeDistance
	if gamestate.settings then
		tempSetting = gamestate.settings.redFadeDistance
	end
	
	if gamestate.settings and gamestate.settings.flagTint and gamestate.players[currentOwnerName] and gamestate.players[currentOwnerName].hasFlag then
		distancecolor = math.min(0.4,1 -(closestOpponent/(tempSetting or defaultRedFadeDistance)))
		scenetree["PostEffectCombinePassObject"]:setField("enableBlueShift", 0, distancecolor)
		scenetree["PostEffectCombinePassObject"]:setField("blueShiftColor", 0, "1 0 0")
	end

	local uiData = {}
	-- local player = gamestate.players[vehicle.ownerName]
	-- local veh = MPVehicleGE.getVehicleByGameID(currentVehID)	

	uiData.gameRunning = true 
	uiData.showFlagArrow = flagMarker.showArrow
	uiData.showFlagIcon = flagMarker.showIcon
	uiData.showFlagHeightArrow = flagMarker.showHeightArrow
	uiData.flagAbovePlayer = flagMarker.abovePlayer
	uiData.flagX = flagMarker.x
	uiData.flagY = flagMarker.y
	uiData.flagAngle = flagMarker.arrowAngle
	uiData.goalAbovePlayer = goalMarker.abovePlayer
	uiData.showGoalArrow = goalMarker.showArrow
	uiData.showGoalHeightArrow = goalMarker.showHeightArrow
	uiData.showGoalIcon = goalMarker.showIcon
	uiData.goalX = goalMarker.x
	uiData.goalY = goalMarker.y
	uiData.goalAngle = goalMarker.arrowAngle
	uiData.showMSGYouScored = uiMessages.showMSGYouScored
	uiData.showMSGLostTheFlag = uiMessages.showMSGLostTheFlag
	uiData.showMSGGotTheFlag = uiMessages.showMSGGotTheFlag
	uiData.showMSGFlagReset = uiMessages.showMSGFlagReset
	uiData.showMSGYouWin = uiMessages.showMSGYouWin
	uiData.showMSGYouLose = uiMessages.showMSGYouLose

	local veh = be:getObjectByID(currentVehID)
	if veh then
		veh:queueLuaCommand('gui.send(\'Transporter\',' .. serialize(uiData) ..')')
	end
	-- log('D', logtag, "Resolution: " .. screenWidth .. "x" .. screenHeight)
end

local function onResetGameplay(id)
	-- log('D', logtag, "onResetGameplay called")
end

local function onExtensionUnloaded()
	resetCarColors()
end

if MPGameNetwork then AddEventHandler("resetCarColors", resetCarColors) end
if MPGameNetwork then AddEventHandler("spawnFlag", spawnFlag) end
if MPGameNetwork then AddEventHandler("spawnGoal", spawnGoal) end
if MPGameNetwork then AddEventHandler("onCreateFlag", onCreateFlag) end
if MPGameNetwork then AddEventHandler("onCreateGoal", onCreateGoal) end
if MPGameNetwork then AddEventHandler("spawnObstacles", spawnObstacles) end
if MPGameNetwork then AddEventHandler("removePrefabs", removePrefabs) end 
if MPGameNetwork then AddEventHandler("setCurrentArea", setCurrentArea) end
if MPGameNetwork then AddEventHandler("requestLevelName", requestLevelName) end 
if MPGameNetwork then AddEventHandler("requestAreaNames", requestAreaNames) end
if MPGameNetwork then AddEventHandler("requestLevels", requestLevels) end
if MPGameNetwork then AddEventHandler("requestFlagCount", requestFlagCount) end
if MPGameNetwork then AddEventHandler("requestGoalCount", requestGoalCount) end
if MPGameNetwork then AddEventHandler("receiveTransporterGameState", receiveTransporterGameState) end
if MPGameNetwork then AddEventHandler("requestTransporterGameState", requestTransporterGameState) end
if MPGameNetwork then AddEventHandler("updateTransporterGameState", updateTransporterGameState) end
if MPGameNetwork then AddEventHandler("sendTransporterContact", sendTransporterContact) end
if MPGameNetwork then AddEventHandler("allowResets", allowResets) end
if MPGameNetwork then AddEventHandler("disallowResets", disallowResets) end
if MPGameNetwork then AddEventHandler("onGameEnd", onGameEnd) end
if MPGameNetwork then AddEventHandler("onGotFlag", onGotFlag) end
if MPGameNetwork then AddEventHandler("onLostFlag", onLostFlag) end
if MPGameNetwork then AddEventHandler("onFlagReset", onFlagReset) end
if MPGameNetwork then AddEventHandler("onScore", onScore) end
if MPGameNetwork then AddEventHandler("onWin", onWin) end
if MPGameNetwork then AddEventHandler("onLose", onLose) end
if MPGameNetwork then AddEventHandler("fadePerson", fadePerson) end
if MPGameNetwork then AddEventHandler("unfadePerson", unfadePerson) end
if MPGameNetwork then AddEventHandler("requestVehicleID", requestVehicleID) end

-- if MPGameNetwork then AddEventHandler("onTransporterFlagTrigger", onTransporterFlagTrigger) end
-- if MPGameNetwork then AddEventHandler("onTransporterGoalTrigger", onTransporterGoalTrigger) end

M.requestTransporterGameState = requestTransporterGameState
M.receiveTransporterGameState = receiveTransporterGameState
M.updateTransporterGameState = updateTransporterGameState
M.requestLevelName = requestLevelName
M.requestAreaNames = requestAreaNames
M.requestLevels = requestLevels
M.requestFlagCount = requestFlagCount
M.requestGoalCount = requestGoalCount
M.sendTransporterContact = sendTransporterContact
M.onPreRender = onPreRender
M.onVehicleSwitched = onVehicleSwitched
M.resetCarColors = resetCarColors
M.spawnFlag = spawnFlag
M.spawnGoal = spawnGoal
M.onCreateFlag = onCreateFlag
M.onCreateGoal = onCreateGoal
M.spawnObstacles = spawnObstacles
M.removePrefabs = removePrefabs
M.setCurrentArea = setCurrentArea
M.onExtensionUnloaded = onExtensionUnloaded
M.onResetGameplay = onResetGameplay
M.onGameEnd = onGameEnd
M.allowResets = allowResets
M.disallowResets = disallowResets
M.onLostFlag = onLostFlag
M.onGotFlag = onGotFlag
M.onScore = onScore
M.onWin = onWin
M.onLose = onLose
M.fadePerson = fadePerson
M.unfadePerson = unfadePerson
M.requestVehicleID = requestVehicleID
-- M.onVehicleResetted = onVehicleResetted
-- M.onTransporterFlagTrigger = onTransporterFlagTrigger
-- M.onTransporterGoalTrigger = onTransporterGoalTrigger
M.onBeamNGTrigger = onBeamNGTrigger
commands.dropPlayerAtCameraNoReset = dropPlayerAtCameraNoReset

return M