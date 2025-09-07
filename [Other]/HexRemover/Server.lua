local errMsg = "* Color codes are not available on this server!"

local function isHEX(s)
	return s:find("#%x%x%x%x%x%x") and s or false
end

local function removeHEX(player)
	local name = getPlayerName(player)
	local s = isHEX(name)
	if s then 
		s = s:gsub("#%x%x%x%x%x%x","")
		setPlayerName(player,s)
		outputChatBox(errMsg,player,255,0,0)
	end
end

local function removeHex_Handler(...)
	if eventName == "onResourceStart" then 
		local playersTable = getElementsByType("player")
		for playerID = 1,#playersTable do 
			local player = playersTable[playerID]
			removeHEX(player)
		end
	elseif eventName == "onPlayerJoin" then 
		removeHEX(source)
	else
		local newNick = arg[2]
		if isHEX(newNick) then 
			cancelEvent()
			outputChatBox(errMsg,source,255,0,0)
		end
	end
end
addEventHandler("onResourceStart",resourceRoot,removeHex_Handler)
addEventHandler("onPlayerJoin",root,removeHex_Handler)
addEventHandler("onPlayerChangeNick",root,removeHex_Handler)