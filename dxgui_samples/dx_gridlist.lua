local screenWidth,screenHeight = guiGetScreenSize()
-- // Items // --
local totalItems = {}
local totalItemsListener = {}
local selectedItem = nil
-- // Grid list // --
local gridlistX = 0
local gridlistY = 0
local gridlistWidth = 200
local gridlistHeight = 300
-- // Render target // --
local renderTarget = nil
local renderTargetX = screenWidth / 2 - gridlistWidth / 2
local renderTargetY = screenHeight / 2 - gridlistHeight / 2
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
-- // Item Font // --
local itemFont = 'default-bold'
local itemScale = 1.0
-- // Custom Events // --
addEvent('onClientDXClick')
addEvent('onElementItemsChanged')
-- // Optimizations // --
local max = math.max
local min = math.min
local floor = math.floor
local ceil = math.ceil
local _remove = table.remove
local _insert = table.insert
 -- // DX-Element for custom events // --
local dxElement = createElement('dx-gridlist-sample')

addEventHandler('onClientResourceStart',resourceRoot,
	function()
		renderTarget = dxCreateRenderTarget(gridlistWidth,gridlistHeight,true)
		dxGridListAddItemsListener()
end)

addEventHandler('onClientRender',root,
	function()
		if renderTarget then			
			dxDrawImage(renderTargetX,renderTargetY,gridlistWidth,gridlistHeight,renderTarget)
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
					local visibleItemsCount = dxGridListGetVisibleItemsCount(false)
					if visibleItemsCount > 0 then
						wheelIndex = theButton == 'mouse_wheel_down' and getwheelIndexFromStepDown(wheelStep) or getwheelIndexFromStepUp(wheelStep)
						scrollbarY = dxScrollBarGetPositionFromwheelIndex()
					end
				end
			elseif theButton == 'mouse1' then
				local insideRectangle,_,relativeY = getRelativeCursorPosition(renderTargetX+scrollbarX,renderTargetY+scrollbarY,scrollbarWidth,scrollbarHeight)
				if insideRectangle then
					scrollbarSelectedPosition = relativeY
				end
				local cursorSelected = dxGridListGetSelectedItemByCursor()
				if cursorSelected then 
					selectedItem = cursorSelected
					triggerEvent('onClientDXClick',dxElement,cursorSelected)
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
		if isCursorShowing() then
			if dxScrollBarIsSelected() then 
				local _,_,relativeY = getRelativeCursorPosition(0,renderTargetY,0,gridlistHeight)
				scrollbarY = relativeY - scrollbarSelectedPosition
				scrollbarY = min(max(scrollbarY,gridlistY),gridlistHeight - scrollbarHeight)
				wheelIndex = getwheelIndexFromScrollBarPosition()
			end
		end
end)

addEventHandler('onElementItemsChanged',dxElement,
	function(k,o,n)
		if dxGridListIsScrollBarAdded() then
			scrollbarHeight = dxScrollBarGetHeight()
			if wheelIndex > 0 then
				scrollbarY = dxScrollBarGetPositionFromwheelIndex()
			end
		end
		
end)

function main()
	dxDrawRectangle(gridlistX,gridlistY,gridlistWidth,gridlistHeight,tocolor(100,100,100,150))
	local totalItemsCount = dxGridListGetItemsCount()
	if totalItemsCount > 0 then
		if dxGridListIsScrollBarAdded() then
			dxDrawRectangle(scrollbarX,gridlistY,scrollbarWidth,gridlistHeight,tocolor(150,150,150,255))
			dxDrawRectangle(scrollbarX,scrollbarY,scrollbarWidth,scrollbarHeight,tocolor(255,255,255,255))
		end
		if selectedItem then
			local itemPos = dxGridListGetItemPosition(selectedItem)
			local itemWidth = dxGridListGetSelectibleWidth()
			local itemHeight = dxGridListGetItemHeight()
			dxDrawRectangle(gridlistX,itemPos,itemWidth,itemHeight,tocolor(0,255,255,200))
		end
		local visibleItems = dxGridListGetVisibleItems()
		for tableIndex = 1,#visibleItems do 
			local indexPosition = dxGridListCalcIndexPosition(tableIndex)
			dxDrawText(visibleItems[tableIndex],gridlistX,indexPosition,0,0,tocolor(255,255,255,255),itemScale,itemFont,'left','top')
		end
	end
end

function dxGridListIsScrollBarAdded()
	local outsideLinesCount = dxGridListGetOutsideLinesCount(false)
	return outsideLinesCount > 0
end

function dxGridListGetItemsCount()
	return #totalItems
end

function dxGridListGetItemText(row)
	return totalItems[row]
end

function getwheelIndexFromStepUp(wheelStep_)
	return max(wheelIndex - wheelStep_,0)
end

function getwheelIndexFromStepDown(wheelStep_)
	local outsideLinesCount = dxGridListGetOutsideLinesCount(false)
	return min(wheelIndex + wheelStep_,outsideLinesCount)
end

function dxScrollBarIsSelected()
	return scrollbarSelectedPosition ~= nil
end

function dxGridListCalcIndexPosition(i)
	local visibleItemsCount = dxGridListGetVisibleItemsCount(true)
	local distrHeight = dxGridListGetCellDistributionHeight()
	local itemHeight = dxGridListGetItemHeight()
	return (i - 1) / visibleItemsCount * distrHeight - wheelIndex % 1 * itemHeight
end

function dxScrollBarGetPositionFromwheelIndex()
	local outsideLinesCount = dxGridListGetOutsideLinesCount(false)
	return wheelIndex / outsideLinesCount * (gridlistHeight - scrollbarHeight)
end

function dxScrollBarGetHeight()
	local visibleItemsCount = dxGridListGetVisibleItemsCount(false)
	local totalItemsCount = dxGridListGetItemsCount()
	return max(visibleItemsCount / totalItemsCount * gridlistHeight,scrollbarMinHeight)
end

function getwheelIndexFromScrollBarPosition()
	local outsideLinesCount = dxGridListGetOutsideLinesCount(false)
	return scrollbarY / (gridlistHeight - scrollbarHeight) * outsideLinesCount
end

function dxGridListGetItemHeight()
	local fontHeight = dxGetFontHeight(itemScale,itemFont)
	return fontHeight
end

function dxGridListGetCellDistributionHeight()
	local itemHeight = dxGridListGetItemHeight()
	local visibleItemsCount = dxGridListGetVisibleItemsCount(true)
	return itemHeight * visibleItemsCount
end

function dxGridListGetVisibleItemsCount(entireVisibleItems)
	local itemHeight = dxGridListGetItemHeight()
	local totalItemsCount = dxGridListGetItemsCount()
	local visibleItemsCount = min(gridlistHeight / itemHeight,totalItemsCount)
	if entireVisibleItems then 
		visibleItemsCount = ceil(visibleItemsCount)
	end
	return visibleItemsCount
end

function dxGridListAddItem(itemText,itemAfter)
	if itemText and type(itemText) == 'string' then
		local insertID = nil
		if itemAfter then
			if totalItems[itemAfter] then
				insertID = itemAfter
			else
				return false
			end
		else
			insertID = #totalItems
		end
		local currentIndex = floor(wheelIndex) + 1
		insertID = insertID + 1
		if currentIndex >= insertID then
			wheelIndex = getwheelIndexFromStepDown(1)
		end
		totalItemsListener[insertID] = itemText
		return true
	end
	return false
end

function dxGridListRemoveItem(itemText,item)
	local itemsCount = dxGridListGetItemsCount()
	if itemsCount > 0 then
		for itemIndex = 1,itemsCount do
			if totalItems[itemIndex] == itemText and itemIndex == item then
				local outsideLinesCount = dxGridListGetOutsideLinesCount(true)
				if outsideLinesCount - wheelIndex <= 0 then 
					wheelIndex = getwheelIndexFromStepUp(1)
				end
				totalItemsListener[itemIndex] = nil
				return true
			end
		end
	end
	return false
end

function dxGridListGetItemPosition(itemIndex)
	local _,currentIndex,lastIndex = dxGridListGetVisibleItems()
	if (itemIndex >= currentIndex or itemIndex <= lastIndex) then
		local visibleItemsCount = dxGridListGetVisibleItemsCount(true)
		local distrHeight = dxGridListGetCellDistributionHeight()
		local itemHeight = dxGridListGetItemHeight()
		return (itemIndex - wheelIndex) / visibleItemsCount * distrHeight - itemHeight
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
		local selectibleWidth = dxGridListGetSelectibleWidth()
		local insideRectangle,_,relativeY = getRelativeCursorPosition(renderTargetX,renderTargetY,selectibleWidth,gridlistHeight)
		if insideRectangle then
			local distrHeight = dxGridListGetCellDistributionHeight()
			local visibleItemsCount = dxGridListGetVisibleItemsCount(true)
			return ceil(relativeY / distrHeight * visibleItemsCount + wheelIndex)
		end
	end
	return nil
end

function dxGridListGetOutsideLinesCount(entireVisibleItems)
	local totalItemsCount = dxGridListGetItemsCount()
	local visibleItemsCount = dxGridListGetVisibleItemsCount(entireVisibleItems)
	return max(0,totalItemsCount - visibleItemsCount)
end

function dxGridListGetVisibleItems() 
	local totalItemsCount = dxGridListGetItemsCount()
	if totalItemsCount > 0 then
		local visibleItemsCount = dxGridListGetVisibleItemsCount(true)
		local visibleItems = {}
		local currentIndex = floor(wheelIndex) + 1
		local lastIndex = currentIndex + min(totalItemsCount,visibleItemsCount)
		for itemIndex = currentIndex,lastIndex do 
			visibleItems[#visibleItems + 1] = totalItems[itemIndex]
		end
		return visibleItems,currentIndex,lastIndex
	end
	return nil
end

function dxGridListAddItemsListener()
	return setmetatable(totalItemsListener,{
		__newindex = function(self,itemKey,itemVal)
			if itemVal == nil then
				if totalItems[itemKey] then
					_remove(totalItems,itemKey)
				end
			else
				_insert(totalItems,itemKey,itemVal)
			end
			triggerEvent('onElementItemsChanged',dxElement,itemKey,self[itemKey],tostring(itemVal))
		end
	})
end

function getRelativeCursorPosition(x,y,width,height)
	if isCursorShowing() then
		local mouseX,mouseY = getCursorPosition()
		local relativeX = min(max((mouseX * screenWidth) - x,0),width)
		local relativeY = min(max((mouseY * screenHeight) - y,0),height)
		local insideRectangle = relativeX > 0 and relativeX < width and relativeY > 0 and relativeY < height
		return insideRectangle,relativeX,relativeY
	end
	return false
end