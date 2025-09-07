local currentMode = nil
local roundState = nil
local isPaused = nil

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		currentMode = exports.tactics:getRoundMapInfo().modename
		roundState = exports.tactics:getRoundState()
		isPaused = exports.tactics:isRoundPaused()
end)

addEventHandler("onClientMapStarting",root,
	function(mapInfo)
		currentMode = mapInfo.modename
end)

addEventHandler("onClientRoundStart",root,
	function()
		roundState = "started"
end)

addEventHandler("onClientRoundFinish",root,
	function()
		roundState = "finished"
end)

addEventHandler("onClientPauseToggle",root,
	function(_isPaused)
		isPaused = _isPaused
end)

addDebugHook('preFunction',
	function(sourceResource)
		if currentMode then
			local resource = getResourceFromName('tactics')
			if resource == sourceResource then 
				if allowedModes[currentMode] then
					if isPaused == false then
						return 'skip'
					end
				end
			end
		end
end,{'setGameSpeed'})

addEventHandler('onClientPlayerDamage',localPlayer,
	function()
		if roundState == "finished" then 
			cancelEvent()
		end
end)