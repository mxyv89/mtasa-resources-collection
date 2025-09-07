local animations = {
	winner={},
	loser={},
	draw={}
}

local function getDancingGroups(winnerTeam)
	local groups = {winner={},loser={},draw={}}
	if winnerTeam and getElementType(winnerTeam) == 'team' then 
		local teams = getElementsByType('team')
		groups.winner = getPlayersInTeam(winnerTeam)
		for i = 1,#teams do 
			if teams[i] ~= winnerTeam then 
				local players = getPlayersInTeam(teams[i])
				for j = 1,#players do 
					groups.loser[#groups.loser+1] = players[j]
				end
			end
		end
	else
		groups.draw = getElementsByType('player')
	end
	return groups
end

local function fromSettingToTable(settingName)
	local settingTable = {}
	local settingValue = get(settingName)
	if settingValue and type(settingValue) == 'string' then
		local strLen = #settingValue
		local commasNumber = 0
		if strLen > 0 then 
			for i = 1,strLen do 
				if settingValue:sub(i,i) == ',' then 
					commasNumber = commasNumber + 1
				end
			end
			if commasNumber == 0 then 
				settingTable[1] = settingValue
			else
				for i = 1,commasNumber+1 do 
					local animationName = gettok(settingValue,i,',')
					settingTable[#settingTable+1] = animationName
				end
			end
		end
	end
	return settingTable
end

addEventHandler('onResourceStart',resourceRoot,
	function()
		animations.winner = fromSettingToTable('winner')
		animations.loser = fromSettingToTable('loser')
		animations.draw = fromSettingToTable('draw')
end)

addEventHandler('onSettingChange',root,
	function(setting,old,new)
		local settingName = gettok(setting,2,'.')
		local resourceName = getResourceName(getThisResource())
		local resourceSetting = '*'..resourceName..'.'..settingName
		if resourceSetting == setting then
			if animations[settingName] then 
				animations.winner = fromSettingToTable('winner')
			end
		end
end)

addEventHandler("onRoundFinish",root,
	function(winner)
		if winner then
			local modeName = exports.tactics:getRoundMapInfo().modename
			if allowedModes[modeName] then
				local groups = nil
				if type(winner) == 'table' then
					groups = getDancingGroups(getTeamFromName(winner[5]))
				else
					groups = getDancingGroups()
				end
				for groupName,groupValue in pairs(groups) do
					local tableLength = #animations[groupName]
					if tableLength > 0 then
						local randomNumber = math.random(1,tableLength)
						local randomString = animations[groupName][randomNumber]
						local blockAnim = gettok(randomString,1,':')
						local animName = gettok(randomString,2,':')
						for i = 1,#groupValue do
							local dancer = groupValue[i]
							setPedAnimation(dancer,blockAnim,animName,-1,true,false,false,true,250,false)
						end
					end
				end
				takeAllWeapons(root)
			end
		end
end)