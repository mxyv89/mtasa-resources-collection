local keysDataTable = {}
local minimalIntervalBetweenKeyClicks = 200 -- // Minimal time between key clicks
local minimalIntervalBetweenWheelClicks = 1 -- // Minimal time between wheel clicks
local minimalIntervalsLimit = 3 -- // If the player has exceeded the minimum time between clicks a given number of times, a report will be sent
local timeForMacroToBeChecked = 3000 -- // How long does it take for the macro to be checked
local minimalLengthForIntervalsCheck = 10 -- // If the interval table size more than the given value, then a check for differences in intervals will be performed
local minimalUnitInterval = 0.5 -- // If the number of equal time intervals in the interval table is more or equal to half the size of this table, then a report will be sent

local function checkForEqualIntervals(button)
	if keysDataTable[button] then 
		local tableLength = #keysDataTable[button].diffTimeStatistics
		if tableLength >= minimalLengthForIntervalsCheck then
			local valueCounter = {}
			for i = 1,tableLength do
				local valueToCheck = keysDataTable[button].diffTimeStatistics[i]
				if valueCounter[valueToCheck] == nil then
					valueCounter[valueToCheck] = 1
					for j = (i+1),tableLength do 
						if valueToCheck == keysDataTable[button].diffTimeStatistics[j] then
							valueCounter[valueToCheck] = valueCounter[valueToCheck] + 1
						end
					end
				end
			end
			local highestNumber = 0
			for _,currentValue in pairs(valueCounter) do 
				if currentValue > highestNumber then 
					highestNumber = currentValue
				end
			end
			local unitInterval = highestNumber / tableLength
			if unitInterval >= minimalUnitInterval then 
				return true,unitInterval
			end
			return false,unitInterval
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

local function fixWheelSprintBug(button)
	if button == "mouse_wheel_down" or button == "mouse_wheel_up" then
		local controlKeys = getBoundKeys('sprint')
		if controlKeys[button] then 
			local pedMoveState = getPedMoveState(localPlayer)
			if pedMoveState == "sprint" then
				cancelEvent()
            end
        end
	end
end

local function checkForMacro(button)
	local currentTick = getTickCount()
	local minTime = (button == 'wheel_mouse_down' or button == 'wheel_mouse_up') and minimalIntervalBetweenWheelClicks or minimalIntervalBetweenKeyClicks
	if keysDataTable[button] == nil then
		keysDataTable[button] = {
			diffTimeStatistics = {},
			warningsCount = 0,
			lastClickTick = nil,
			firstClickTick = nil
		}
	end
	if keysDataTable[button].lastClickTick then 
		local diffTime = currentTick - keysDataTable[button].lastClickTick
		if diffTime < minTime then
			keysDataTable[button].warningsCount = keysDataTable[button].warningsCount + 1
		end
		keysDataTable[button].diffTimeStatistics[#keysDataTable[button].diffTimeStatistics+1] = diffTime
	end
	if keysDataTable[button].firstClickTick then
		if currentTick - keysDataTable[button].firstClickTick > timeForMacroToBeChecked then
			local fastClickerReport = keysDataTable[button].warningsCount and keysDataTable[button].warningsCount > minimalIntervalsLimit
			local isIntervalCheck,unitInterval = checkForEqualIntervals(button)
			if fastClickerReport or isIntervalCheck then
				local unitIntervalData = unitInterval and (unitInterval * 100)..'%' or 'not enough intervals to check'
				triggerServerEvent('onPlayerPunish',localPlayer,keysDataTable[button].warningsCount,unitIntervalData)
			end
			keysDataTable[button] = nil
		end
	else
		keysDataTable[button].firstClickTick = currentTick
	end
	if keysDataTable[button] then
		keysDataTable[button].lastClickTick = currentTick
	end
end

addEventHandler("onClientPreRender",root,
	function()
		fixWeaponFistBug()
end)

addEventHandler("onClientKey",root,
	function(button,isPressed)
		if isPressed then 
			fixWheelSprintBug(button)
			checkForMacro(button)
		end
end)