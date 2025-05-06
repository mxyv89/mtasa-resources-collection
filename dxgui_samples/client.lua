local screenWidth,screenHeight = guiGetScreenSize()
-- // Global items // --
local totalItems = {}
local totalItemsListener = {}
-- // Grid list // --
local gridlistX = 0
local gridlistY = 0
local gridlistWidth = 200
local gridlistHeight = 304
-- // Render target // --
local renderTarget = nil
local renderTargetX = (screenWidth / 2) - (gridlistWidth / 2)
local renderTargetY = (screenHeight / 2) - (gridlistHeight / 2)
-- // Scroll bar // --
local scrollbarX = (gridlistX + gridlistWidth) - 15
local scrollbarY = gridlistY
local scrollbarWidth = 15
local scrollbarHeight = 0
local scrollbarMinHeight = 10
local scrollbarSelectedPosition = nil
-- // Wheel // --
local wheelIndex = 0
local wheelStep = 0.5
-- // Item font // --
local itemFont = 'default-bold'
local itemScale = 1.0
-- // Custom events // --
addEvent('onClientDXClick')
addEvent('onClientItemsChanged')
-- // Optimizations // --
local max = math.max
local min = math.min
local floor = math.floor
local ceil = math.ceil
local remove_ = table.remove
local insert_ = table.insert

addEventHandler('onClientResourceStart',resourceRoot,
	function()
		renderTarget = dxCreateRenderTarget(gridlistWidth,gridlistHeight,true)
		dxGridListAddItemsListener()
end)

addEventHandler('onClientRender',root,
	function()
		if renderTarget then
			dxDrawImage(renderTargetX,renderTargetY,gridlistWidth,gridlistHeight,renderTarget)
			updateRT()
		end
end)

addEventHandler('onClientKey',root,
	function(theButton,isButtonPressed)
		if isButtonPressed then
			if theButton == 'mouse_wheel_down' or theButton == 'mouse_wheel_up' then
				if getRelativeCursorPosition(renderTargetX,renderTargetY,gridlistWidth,gridlistHeight) then
					if dxGridListGetVisibleItemsCount(false) > 0 then
						wheelIndex = theButton == 'mouse_wheel_down' and wheelKeyMoveDown(wheelStep) or wheelKeyMoveUP(wheelStep)
						-- // Set the position of the scrollbar depending on the mouse wheel index // --
						scrollbarY = getScrollBarPositionFromWheelIndex()
					end
				end
			elseif theButton == 'mouse1' then
				local isInRect,relativeX,relativeY = getRelativeCursorPosition(renderTargetX+scrollbarX,renderTargetY+scrollbarY,scrollbarWidth,scrollbarHeight)
				if (isInRect) then
					scrollbarSelectedPosition = relativeY
				end
				local selectedItem = dxGridListGetSelectedItemByCursor()
				if (selectedItem) then 
					triggerEvent('onClientDXClick',resourceRoot,selectedItem)
				end
			end
		else
			if theButton == 'mouse1' then
				scrollbarSelectedPosition = nil
			end
		end
end)
 
addEventHandler('onClientCursorMove',root,
	function()
		if (isCursorShowing()) then
			local _,_,relativeY = getRelativeCursorPosition(0,renderTargetY,0,gridlistHeight)
			if dxScrollBarIsSelected() then 
				scrollbarY = relativeY - scrollbarSelectedPosition
				-- // Preventing the scrollbar from going outside the gridlist // --
				scrollbarY = min(max(scrollbarY,gridlistY),gridlistHeight - scrollbarHeight)
				-- // Set the scroll wheel index depending on the position of the scrollbar // --
				wheelIndex =  getWheelIndexFromScrollBarPosition()
			end
		end
end)

addEventHandler('onClientItemsChanged',resourceRoot,
	function()
		if dxGridListIsScrollBarAdded() then
			scrollbarY = getScrollBarPositionFromWheelIndex()
			scrollbarHeight = getScrollBarHeight()
		end
end)

function main()
	dxDrawRectangle(gridlistX,gridlistY,gridlistWidth,gridlistHeight,tocolor(150,150,150,150))
	if (dxGridListGetRowCount() > 0) then 
		if (dxGridListIsScrollBarAdded()) then
			dxDrawRectangle(scrollbarX,gridlistY,scrollbarWidth,gridlistHeight,tocolor(255,255,255,150))
			dxDrawRectangle(scrollbarX,scrollbarY,scrollbarWidth,scrollbarHeight,tocolor(255,255,255,255))
		end
		local visibleItems = dxGridListGetVisibleItems()
		for i = 1,#visibleItems do 
			local indexPosition = dxGridListCalcIndexPosition(i)
			dxDrawText(visibleItems[i],gridlistX,indexPosition,0,0,tocolor(255,255,255,255),itemScale,itemFont,'left','top')
		end
	end
end

function updateRT()
	dxSetRenderTarget(renderTarget,true)	
	dxSetBlendMode('modulate_add')	
	main()	
	dxSetBlendMode('blend')	
	dxSetRenderTarget()
end

function dxGridListIsScrollBarAdded()
	return dxGridListGetOutsideLinesCount(false) > 0
end

function dxGridListAddItem(text)
	totalItemsListener[#totalItems+1] = text
end

function dxGridListInsertItemAfter()
	
end

function dxGridListGetRowCount()
	return #totalItems
end

function dxGridListGetItemText(row)
	return totalItems[row]
end

function wheelKeyMoveUP(wheelStep_)
	return max(wheelIndex - wheelStep_,0)
end

function wheelKeyMoveDown(wheelStep_)
	return min(wheelIndex + wheelStep_,dxGridListGetOutsideLinesCount(false))
end

function dxScrollBarIsSelected()
	return scrollbarSelectedPosition ~= nil
end

function dxGridListCalcIndexPosition(i)
	return (i - 1) / dxGridListGetVisibleItemsCount(true) * dxGridListGetCellDistributionHeight() - wheelIndex % 1 * dxGridListGetItemHeight()
end

function getScrollBarPositionFromWheelIndex()
	return gridlistY + ((wheelIndex / dxGridListGetOutsideLinesCount(false)) * (gridlistHeight - scrollbarHeight))
end

function getScrollBarHeight()
	return max(dxGridListGetVisibleItemsCount(false) / dxGridListGetRowCount() * gridlistHeight,scrollbarMinHeight)
end

function getWheelIndexFromScrollBarPosition()
	return scrollbarY / (gridlistHeight - scrollbarHeight) * dxGridListGetOutsideLinesCount(false)
end

function dxGridListGetItemHeight()
	return dxGetFontHeight(itemScale,itemFont)
end

function dxGridListGetCellDistributionHeight()
	return dxGridListGetItemHeight() * dxGridListGetVisibleItemsCount(true)
end

function dxGridListAddItemsListener()
	
end

function dxGridListGetVisibleItemsCount(isTotalItems)
	local visibleItemsCount = min(gridlistHeight / dxGridListGetItemHeight(),dxGridListGetRowCount())
	if isTotalItems then 
		return ceil(visibleItemsCount)
	end
	return visibleItemsCount
end

function dxGridListRemoveItem(text,row)
	local itemCount = dxGridListGetRowCount()
	if itemCount > 0 then
		for i = 1,itemCount do
			if totalItems[i] == text and i == row then
				if dxGridListGetOutsideLinesCount(true) - wheelIndex <= 0 then 
					wheelIndex = wheelKeyMoveUP(1)
				end
				totalItemsListener[i] = nil
				return true
			end
		end
	end
	return false
end

function dxGridListGetItemPosition(id)
	local _,startIndex,endIndex = dxGridListGetVisibleItems()
	if (id >= startIndex or id <= endIndex) then
		return ((id - wheelIndex) / dxGridListGetVisibleItemsCount(true) * dxGridListGetCellDistributionHeight()) - dxGridListGetItemHeight()
	end
	return nil
end

function dxGridListGetSelectibleWidth()
	if dxGridListIsScrollBarAdded() then 
		return gridlistWidth - scrollbarWidth
	end
	return gridlistWidth
end

function dxGridListGetSelectedItemByCursor()
	if isCursorShowing() then
		local isInRectangle,_,relativeY = getRelativeCursorPosition(renderTargetX,renderTargetY,gridlistWidth,gridlistHeight)
		if isInRectangle then
			return ceil(relativeY / dxGridListGetCellDistributionHeight() * dxGridListGetVisibleItemsCount(true) + wheelIndex)
		end
	end
	return nil
end

function dxGridListGetOutsideLinesCount(isTotalItems)
	return max(0,(dxGridListGetRowCount() - dxGridListGetVisibleItemsCount(isTotalItems)))
end

function dxGridListGetVisibleItems() 
	local rowCount = dxGridListGetRowCount()
	if rowCount > 0 then
		local visibleItems = {}
		local startIndex = floor(wheelIndex) + 1
		local endIndex = startIndex + min(rowCount,dxGridListGetVisibleItemsCount(true))
		for i = startIndex,endIndex do 
			visibleItems[#visibleItems+1] = totalItems[i]
		end
		return visibleItems,startIndex,endIndex
	end
	return nil
end

function dxGridListAddItemsListener()
	return setmetatable(totalItemsListener,{
		__newindex = function(t,k,v)
			if v == nil then
				if totalItems[k] then
					remove_(totalItems,k)
				end
			else
				insert_(totalItems,k,v)
			end
			triggerEvent('onClientItemsChanged',resourceRoot)
		end
	})
end

function getRelativeCursorPosition(x,y,w,h)
	if isCursorShowing() then
		local mouseX,mouseY = getCursorPosition()
		local relativeX = min(max((mouseX * screenWidth) - x,0),w)
		local relativeY = min(max((mouseY * screenHeight) - y,0),h)
		local isInRect = relativeX > 0 and relativeX < w and relativeY > 0 and relativeY < h
		return isInRect,relativeX,relativeY
	end
	return false
end


------------------------------------------------------------------------------------------

addEventHandler('onClientResourceStart',resourceRoot,
function()
	local weapons = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 22, 23, 24, 25, 26, 27, 28, 29, 32, 30, 31, 33, 34, 35, 36, 37, 38, 16, 17, 18, 39, 41, 42, 43, 10, 11, 12, 14, 15, 44, 45, 46, 40}
	for i = 1,30 do
		local weaponName = i
		dxGridListAddItem('Number '..i)
	end
end)

addEventHandler('onClientDXClick',resourceRoot,
function(item)
	local text = dxGridListGetItemText(item)
	if (text) then
		dxGridListRemoveItem(text,item)
	end
end)