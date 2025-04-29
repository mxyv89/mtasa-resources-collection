local reportFilePath = 'reports/macro_reports.xml'
local isReportEnabled = true

local function writeReport(serialNumber,playerName,warningsCount,unitInterval)
	local xmlReportFile = nil
	if fileExists(reportFilePath) == false then
		xmlReportFile = xmlCreateFile(reportFilePath,'serials')
	else
		xmlReportFile = xmlLoadFile(reportFilePath)
	end
	if xmlReportFile then 
		local xmlSerialNode = nil
		local xml_children = xmlNodeGetChildren(xmlReportFile)
		if xml_children and #xml_children > 0 then 
			for i = 1,#xml_children do 
				local currNode = xml_children[i]
				local nodeName = xmlNodeGetName(currNode)
				if nodeName == serialNumber then 
					xmlSerialNode = currNode
					break
				end
			end
		end
		if xmlSerialNode == nil then
			xmlSerialNode = xmlCreateChild(xmlReportFile,serialNumber)
		end
		local xmlDataNode = xmlCreateChild(xmlSerialNode,'data')
		if xmlDataNode then
			local time = getRealTime()
			local timeStr = string.format("%04d-%02d-%02d %02d:%02d:%02d",time.year + 1900,time.month + 1,time.monthday,time.hour,time.minute,time.second)
			xmlNodeSetAttribute(xmlDataNode,'player_name',playerName)
			xmlNodeSetAttribute(xmlDataNode,'equal_intervals_number',unitInterval)
			xmlNodeSetAttribute(xmlDataNode,'min_interval_warnings',warningsCount)
			xmlNodeSetAttribute(xmlDataNode,'time',timeStr)
		end
		xmlSaveFile(xmlReportFile)
		xmlUnloadFile(xmlReportFile)
		return true
	 end
	 return false
end

addEventHandler('onSettingChange',root,
	function()
		
end)

addEventHandler('onResourceStart',resourceRoot,
	function()
		
end)

addEvent('onPlayerPunish',true)
addEventHandler('onPlayerPunish',root,
	function(warningsCount,unitInterval)
		if isReportEnabled then
			writeReport(getPlayerSerial(source),getPlayerName(source),warningsCount,unitInterval)
		else
			if hasObjectPermissionTo(getThisResource(),'function.kickPlayer') then 
				kickPlayer(source,'Kicked by using macro hack!')
			else
				outputServerLog('* Unable to kick the player')
			end
		end
end)
