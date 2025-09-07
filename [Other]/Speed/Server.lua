function setPlayerSpeed(player,speed)
	if isElement(player) and getElementType(player) == 'player' then 
		if speed and type(speed) == 'number' and speed >= 0 and speed <= 10 then
			triggerClientEvent(player,'onClientSetSpeed',player,speed)
			if speed > 0 then
				if getPlayerSpeed(player) ~= speed then
					return setElementData(player,'player.speed',speed,false)
				end
			else
				if getPlayerSpeed(player) > 0 then 
					return removeElementData(player,'player.speed')
				end
			end
		end
	end
	return false
end

function getPlayerSpeed(player)
	if isElement(player) and getElementType(player) == 'player' then 
		if hasElementData(player,'player.speed') then 
			return getElementData(player,'player.speed')
		end
		return 0
	end
	return false
end

addEventHandler('onResourceStop',resourceRoot,
	function()
		for id,player in ipairs(getElementsByType('player')) do
			if hasElementData(player,'player.speed') then
				removeElementData(player,'player.speed')
			end
		end
end)

addCommandHandler('player_speed',
	function(player,command,name,speed)
		if hasObjectPermissionTo(player,'command.player_speed',false) then 
			if name and speed then
				local playerSource = getPlayerFromName(name)
				local playerSpeed = tonumber(speed)
				if playerSource and playerSpeed then
					if playerSpeed >= 0 and playerSpeed <= 10 then
						if setPlayerSpeed(playerSource,playerSpeed) then
							outputChatBox('* You have successfully set the speed for the player!',player,255,255,255)
							outputChatBox("* Player - "..name,player,255,255,255,true)
							outputChatBox("* Speed - "..speed,player,255,255,255)
						else
							outputChatBox("* Trying to set the same speed!",player,255,0,0)
						end
					end
				else
					outputChatBox('* Wrong arguments!',player,255,0,0)
				end
			else
				outputChatBox('* No arguments!',player,255,0,0)
			end
		else
			outputChatBox('* You dont have permission to do this!',player,255,0,0)
		end
end)