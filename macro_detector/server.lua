local reportFilePath = 'reports/macro_reports.xml'
local isReportEnabled = nil
local resourceName = getResourceName(resource)
local settingName = '*'..resourceName..'.report'

local function writeReport(serialNumber,playerName,warningsCount,unitInterval,buttonName)
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
			xmlNodeSetAttribute(xmlDataNode,'button_name',buttonName)
			xmlNodeSetAttribute(xmlDataNode,'equal_intervals_number',unitInterval)
			xmlNodeSetAttribute(xmlDataNode,'min_interval_warnings',warningsCount)
			xmlNodeSetAttribute(xmlDataNode,'report_time',timeStr)
		end
		xmlSaveFile(xmlReportFile)
		xmlUnloadFile(xmlReportFile)
		return true
	 end
	 return false
end

addEventHandler('onSettingChange',root,
	function(setting,old,new)
		if setting == settingName then 
			local changedValue = fromJSON(new)
			isReportEnabled = changedValue == 'true'
		end
end)

addEventHandler('onResourceStart',resourceRoot,
	function()
		isReportEnabled = get(settingName) == 'true'
end)

addEvent('onPlayerPunish',true)
addEventHandler('onPlayerPunish',root,
	function(warningsCount,unitInterval,buttonName)
		if isReportEnabled then
			writeReport(getPlayerSerial(source),getPlayerName(source),warningsCount,unitInterval,buttonName)
		else
			if hasObjectPermissionTo(getThisResource(),'function.kickPlayer') then 
				kickPlayer(source,'You are suspected of using a macro')
			else
				outputServerLog('The resource <'..resourceName..'> does not have <function.kickPlayer> right')
			end
		end
end)
