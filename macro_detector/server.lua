local reportFilePath = 'reports/macro_reports.xml'
local isReportEnabled = true

local function writeReport(serial,name,warnings)
	 local xml_file = xmlLoadFile(reportFilePath)
	 if xml_file then 
		local currentTime = getCurrentTime()
		local xmlNode = nil
		local xml_children = xmlNodeGetChildren(xml_file)
		if xml_children and #xml_children > 0 then 
			for i = 1,#xml_children do 
				local currNode = xml_children[i]
				local nodeName = xmlNodeGetName(currNode)
				if nodeName == serial then 
					xmlNode = currNode
					break
				end
			end
		end
		if xmlNode == nil then
			xmlNode = xmlCreateChild(xml_file,serial)
		end
		local xmlData = xmlCreateChild(xmlNode,'data')
		if xmlData then
			local time = getRealTime()
			local timeStr = string.format("%04d-%02d-%02d %02d:%02d:%02d", time.year + 1900, time.month + 1, time.monthday, time.hours, time.minutes, time.seconds)
			xmlNodeSetAttribute(xmlData,'name',name)
			xmlNodeSetAttribute(xmlData,'warnings',warnings)
			xmlNodeSetAttribute(xmlData,'time',timeStr)
		end
		xmlSaveFile(xml_file)
		xmlUnloadFile(xml_file)
		return true
	 end
	 return false
end

addEventHandler('onResourceStart',resourceRoot,
	function()
		if isReportEnabled then
			if fileExists(reportFilePath) == false then 
				local xml_file = xmlCreateFile(reportFilePath,'serials')
				xmlSaveFile(xml_file)
				xmlUnloadFile(xml_file)
			end
		end
end)

addEvent('onPlayerPunish',true)
addEventHandler('onPlayerPunish',root,
	function(warningsCount)
		if isReportEnabled then
			writeReport(getPlayerSerial(source),getPlayerName(source),warningsCount)
		else
			if hasObjectPermissionTo(getThisResource(),'function.kickPlayer') then 
				kickPlayer(source,'Kicked by using macro hack!')
			else
				outputServerLog('* Unable to kick the player')
			end
		end
end)
