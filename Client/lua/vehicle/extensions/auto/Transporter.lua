local M = {}

local gamestate = {players = {}, settings = {}}

local uiData = {}


--local originalstartRecovery = recovery.startRecovering
--local originalstopRecovery = recovery.stopRecovering()
--
--local function newStartRecovering(useAltMode)
--	if gamestate.gameRunning then return end
--	originalstartRecovery(useAltMode)
--end
--local function newStopRecovering()
--	if gamestate.gameRunning then return end
--	originalstopRecovery()
--end
--
--recovery.startRecovering = newStartRecovering
--recovery.stopRecovering = newStopRecovering

local function setTransporterGameState(data)
	--local data = jsonDecode(data)
	gamestate = data
end

local function mergeTable(table,gamestateTable)
	for variableName,value in pairs(table) do
		if type(value) == "table" then
			mergeTable(value,gamestateTable[variableName])
		elseif value == "remove" then
			gamestateTable[variableName] = nil
		else
			gamestateTable[variableName] = value
		end
	end
end

local function updateTransporterGameState(data)
	mergeTable(data,gamestate)
	dump(gamestate)
end

-- local function updateUI(data)
-- 	uiData = data
-- end

-- local function updateGFX(dt)
-- 	-- uiData.showFlagArrow = flagMarker.showArrow
-- 	-- uiData.showFlagIcon = flagMarker.showIcon
-- 	-- uiData.showFlagHeightArrow = flagMarker.showHeightArrow
-- 	-- uiData.flagAbovePlayer = flagMarker.abovePlayer
-- 	-- uiData.flagX = flagMarker.x
-- 	-- uiData.flagY = flagMarker.y
-- 	-- uiData.flagAngle = flagMarker.arrowAngle
-- 	-- uiData.goalAbovePlayer = goalMarker.abovePlayer
-- 	-- uiData.showGoalArrow = goalMarker.showArrow
-- 	-- uiData.showGoalHeightArrow = goalMarker.showHeightArrow
-- 	-- uiData.showGoalIcon = goalMarker.showIcon
-- 	-- uiData.goalX = goalMarker.x
-- 	-- uiData.goalY = goalMarker.y
-- 	-- uiData.goalAngle = goalMarker.arrowAngle

-- 	-- goalMarker.x = goalMarker.x - 1
-- 	-- flagMarker.arrowAngle = flagMarker.arrowAngle + 1
	
-- 	gui.send("Transporter", uiData) --TODO: this data doesn't seem to come through correctly
-- end


M.setTransporterGameState = setTransporterGameState
M.updateTransporterGameState = updateTransporterGameState
-- M.updateGFX = updateGFX

return M