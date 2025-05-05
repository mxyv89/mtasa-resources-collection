local screenWidth,screenHeight = guiGetScreenSize()
local totalItems = {}
local renderTarget = nil
local gridlistX = 0
local gridlistY = 0
local gridlistWidth = 200
local gridlistHeight = 300
local renderTargetX = (screenWidth / 2) - (gridlistWidth / 2)
local renderTargetY = (screenHeight / 2) - (gridlistHeight / 2)
local scrollbarX = (gridlistX + gridlistWidth) - 20
local scrollbarY = gridlistY
local scrollbarWidth = 15
local scrollbarHeight = 0
local scrollbarMinHeight = 10
local wheelIndex = 0
local wheelStep = 0.5
local scrollbarSelectedPosition = nil
local itemFont = 'default-bold'
local itemScale = 1.0
-- // Custom Events // --
addEvent('onClientDXClick')
-- // Optimizations // --
local max = math.max
local min = math.min
local floor = math.floor
local ceil = math.ceil

addEventHandler('onClientResourceStart',resourceRoot,
	function()
		renderTarget = dxCreateRenderTarget(gridlistWidth,gridlistHeight,true)
		dxGridListAddItemsListener()
end)

addEventHandler('onClientRender',root,
	function()
		if renderTarget then
			-- // Draw render target -- //
			dxDrawImage(renderTargetX,renderTargetY,gridlistWidth,gridlistHeight,renderTarget)
			-- // Update render target -- //
			dxSetRenderTarget(renderTarget,true)	
			dxSetBlendMode('modulate_add')	
			main()	
			dxSetBlendMode('blend')	
			dxSetRenderTarget()
		end
end)

addEventHandler('onClientKey',root,
	function(theButton,isButtonPressed)
		if isButtonPressed then
			if theButton == 'mouse_wheel_down' or theButton == 'mouse_wheel_up' then
				if getRelativeCursorPosition(renderTargetX,renderTargetY,gridlistWidth,gridlistHeight) then
					if dxGridListGetTotalVisibleItems() > 0 then
						local outsideLines = dxGridListGetOutsideLinesCount()
						wheelIndex = theButton == 'mouse_wheel_down' and wheelKeyMoveDown() or wheelKeyMoveUP()
						scrollbarY = getScrollBarPositionFromWheelIndex() --// Set the position of the scrollbar depending on the mouse wheel index
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
			-- // if there was a capture of the scrollbar then drag it with the mouse // --
			if dxScrollBarIsSelected() then 
				scrollbarY = relativeY - scrollbarSelectedPosition
				-- // Preventing the scrollbar from going outside the gridlist // --
				scrollbarY = min(max(scrollbarY,gridlistY),gridlistHeight - scrollbarHeight)
				-- // Set the scroll wheel index depending on the position of the scrollbar // --
				wheelIndex =  getWheelIndexFromScrollBarPosition()
			end
		end
end)

function main()
	dxDrawRectangle(gridlistX,gridlistY,gridlistWidth,gridlistHeight,tocolor(150,150,150,150))
	local rowCount = dxGridListGetRowCount()
	if (rowCount > 0) then 
		if (dxGridListIsScrollBarAdded()) then
			dxDrawRectangle(scrollbarX,gridlistY,scrollbarWidth,gridlistHeight,tocolor(255,255,255,150))
			dxDrawRectangle(scrollbarX,scrollbarY,scrollbarWidth,scrollbarHeight,tocolor(255,255,255,255))
		end
		local visibleItems = dxGridListGetCurrentVisibleItems()
		for i = 1,#visibleItems do 
			local itemText = visibleItems[i]
			local smoothMovement = wheelIndex % 1 * dxGridListGetItemHeight()
			local itemPos = (i - 1) / dxGridListGetTotalVisibleItems() * dxGridListGetCellDistributionHeight() - smoothMovement -- Set the position of each item depending on the relative height
			dxDrawText(itemText,gridlistX,itemPos,0,0,tocolor(255,255,255,255),itemScale,itemFont,'left','top')
		end
		--[[local selectedItem = dxGridListGetSelectedItemByCursor()
		if (selectedItem) then
			local itemPos = dxGridListGetItemPos(selectedItem)
			if (itemPos) then 
				local selectibleWidth = dxGridListGetSelectibleWidth()
				--dxDrawRectangle(gridlistX,itemPos,selectibleWidth,itemHeight,itemSelectColor)
			end
		end]]
	end
end

function dxGridListIsScrollBarAdded()
	return dxGridListGetOutsideLinesCount() > 0
end

function dxGridListAddItem(text)
	totalItems[#totalItems+1] = text
end

function dxGridListGetRowCount()
	return #totalItems
end

function dxGridListGetItemText(row)
	return totalItems[row]
end

function wheelKeyMoveUP()
	return max(wheelIndex - wheelStep,0)
end

function wheelKeyMoveDown()
	return min(wheelIndex + wheelStep,dxGridListGetOutsideLinesCount())
end

function dxScrollBarIsSelected()
	return scrollbarSelectedPosition ~= nil
end

function getScrollBarPositionFromWheelIndex()
	return gridlistY + ((wheelIndex / dxGridListGetOutsideLinesCount()) * (gridlistHeight - scrollbarHeight))
end

function getScrollBarHeight()
	return max(dxGridListGetTotalVisibleItems() / dxGridListGetRowCount() * gridlistHeight,scrollbarMinHeight)
end

function getWheelIndexFromScrollBarPosition()
	return scrollbarY / (gridlistHeight - scrollbarHeight) * dxGridListGetOutsideLinesCount()
end

function dxGridListGetItemHeight()
	return dxGetFontHeight(itemScale,itemFont)
end

function dxGridListGetCellDistributionHeight()
	return min(dxGridListGetRowCount() * dxGridListGetItemHeight(),gridlistHeight)
end

function dxGridListGetTotalVisibleItems()
	return min(gridlistHeight / dxGridListGetItemHeight(),dxGridListGetRowCount())
end

function dxGridListAddItemsListener()
	setmetatable(totalItems,{
		__newindex = function(t,k,v)
			rawset(t,k,v)
			if dxGridListIsScrollBarAdded() then
				scrollbarHeight = getScrollBarHeight()
			end
		end
	})
end

function dxGridListRemoveItem(text,row)
	local itemCount = dxGridListGetRowCount()
	if itemCount > 0 then
		for i = 1,itemCount do
			if (totalItems[i] == text and i == row) then
				local _,_,endIndex = dxGridListGetCurrentVisibleItems()
				if endIndex == dxGridListGetRowCount() then 
					wheelKeyMoveUP()
				end
				table.remove(totalItems,row)
				return true
			end
		end
	end
	return false
end

function dxGridListGetItemPosition(id)
	local _,startIndex,endIndex = dxGridListGetCurrentVisibleItems()
	if (id >= startIndex or id <= endIndex) then
		return ((id - wheelIndex) / dxGridListGetTotalVisibleItems() * dxGridListGetCellDistributionHeight()) - dxGridListGetItemHeight()
	end
	return nil
end

function dxGridListGetSelectibleWidth()
	if dxGridListGetOutsideLinesCount() > 0 then 
		return gridlistWidth - scrollbarWidth
	end
	return gridlistWidth
end

function dxGridListGetSelectedItemByCursor()
	if isCursorShowing() then
		local isInRectangle,_,relativeY = getRelativeCursorPosition(renderTargetX,renderTargetY,gridlistWidth,gridlistHeight)
		if isInRectangle then
			return ceil((relativeY / dxGridListGetCellDistributionHeight() * dxGridListGetTotalVisibleItems()) + wheelIndex)
		end
	end
	return nil
end

function dxGridListGetOutsideLinesCount()
	return max(0,(dxGridListGetRowCount() - dxGridListGetTotalVisibleItems()))
end

function dxGridListGetCurrentVisibleItems() 
	local rowCount = dxGridListGetRowCount()
	if rowCount > 0 then
		local visibleItems = {}
		local startIndex = floor(wheelIndex) + 1
		local endIndex = startIndex + min(rowCount,dxGridListGetTotalVisibleItems())
		for i = startIndex,endIndex do 
			visibleItems[#visibleItems+1] = totalItems[i]
		end
		return visibleItems,startIndex,endIndex
	end
	return nil,nil,nil
end

function getRelativeCursorPosition(x,y,w,h)
	if isCursorShowing() then
		local mouseX,mouseY = getCursorPosition()
		local relativeX = min(max((mouseX * screenWidth) - x,0),w)
		local relativeY = min(max((mouseY * screenHeight) - y,0),h)
		local isInRect = relativeX > 0 and relativeX < w and relativeY > 0 and relativeY < h
		return isInRect,relativeX,relativeY
	end
	return false,nil,nil
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