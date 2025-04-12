local modeNames = {arena=true,ctf=true}

addDebugHook('preFunction',
	function(sourceResource)
		local resource = getResourceFromName('tactics')
		if resource == sourceResource then 
			local modeName = exports.tactics:getRoundMapInfo().modename
			if modeNames[modeName] then
				local isPaused = exports.tactics:isRoundPaused()
				if isPaused == false then
					return 'skip'
				end
			end
		end
end,{'setGameSpeed'})

addEventHandler('onClientPlayerDamage',localPlayer,
	function()
		local roundState = exports.tactics:getRoundState()
		if roundState == 'finished' then 
			cancelEvent()
		end
end)