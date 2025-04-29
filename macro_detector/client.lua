local keysDataTable = {}
local minKeyTime = 200 -- // Minimal time between key clicks
local minWheelTime = 1 -- // Minimal time between wheel(down or up) clicks
local timeForCheck = 3000 -- // How long does it take for the macro to be checked
local warningsLimit = 3 -- // If the value reaches more than this value,then a report will be sent
local minTableLengthToAnalyze = 10

local function doesTheUserHaveMacro(button)
	if keysDataTable[button] then 
		local tableLength = #keysDataTable[button].diffTimeStatistics
		if tableLength > minTableLengthToAnalyze then
			local checkedValues = {}
			for i = 1,tableLength do
				local valueToCheck = keysDataTable[button].diffTimeStatistics[i]
				if checkedValues[valueToCheck] == nil then
					local valueCount = 0
					for j = 1,tableLength do 
						if valueToCheck == keysDataTable[button].diffTimeStatistics[j] then
							valueCount = valueCount + 1
						end
					end
					checkedValues[valueCount] = valueCount
				end
			end
			local maxValue = getTableMaxValue(checkedValues)
			if maxValue > tableLength / 2 then 
				return true
			end
		end
	end
	return false
end

local function fixWeaponFistBug()
	local taskSimpleFight = getPedTask(localPlayer,"secondary",0) == "TASK_SIMPLE_FIGHT"
	local taskSimpleFightCtrl = getPedTask(localPlayer,"secondary",0) == "TASK_SIMPLE_FIGHT_CTRL"
	local nonZeroWeapon = getPedWeapon(localPlayer) ~= 0
	if taskSimpleFight and taskSimpleFightCtrl and nonZeroWeapon then 
		setPedWeaponSlot(localPlayer,0)
	end
end

local function fixWheelSprintBug(theButton)
	if theButton == "mouse_wheel_down" or theButton == "mouse_wheel_up" then
		local controlKeys = getBoundKeys('sprint')
		if controlKeys[theButton] then 
			local pedMoveState = getPedMoveState(localPlayer)
			if pedMoveState == "sprint" then
				cancelEvent()
            end
        end
	end
end

local function checkForMacro(theButton)
	local currentTick = getTickCount()
	local minTime = (theButton == 'wheel_mouse_down' or theButton == 'wheel_mouse_up') and minWheelTime or minKeyTime
	if keysDataTable[theButton] == nil then
		keysDataTable[theButton] = {
			diffTimeStatistics = {},
			warningsCount = 0,
			lastClickTick = nil,
			firstClickTick = nil
		}
	end
	if keysDataTable[theButton].lastClickTick then 
		local diffTime = currentTick - keysDataTable[theButton].lastClickTick
		if diffTime < minTime then
			keysDataTable[theButton].warningsCount = keysDataTable[theButton].warningsCount + 1
		end
		keysDataTable[theButton].diffTimeStatistics[#keysDataTable[theButton].diffTimeStatistics+1] = diffTime
	end
	if keysDataTable[theButton].firstClickTick then
		if currentTick - keysDataTable[theButton].firstClickTick > timeForCheck then
			local fastClickerReport = keysDataTable[theButton].warningsCount and keysDataTable[theButton].warningsCount > warningsLimit
			if fastClickerReport then
				triggerServerEvent('onPlayerPunish',localPlayer,keysDataTable[theButton].warningsCount)
			end
			keysDataTable[theButton] = nil
		end
	else
		keysDataTable[theButton].firstClickTick = currentTick
	end
	if keysDataTable[theButton] then
		keysDataTable[theButton].lastClickTick = currentTick
	end
end

addEventHandler("onClientPreRender",root,
	function()
		fixWeaponFistBug()
end)

addEventHandler("onClientKey",root,
	function(theButton,isPressed)
		if isPressed then 
			fixWheelSprintBug(theButton)
			checkForMacro(theButton)
		end
end)