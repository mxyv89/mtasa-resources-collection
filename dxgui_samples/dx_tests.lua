addEventHandler('onClientResourceStart',resourceRoot,
function()
	-- // dxGridList test // --
	local weaponItems = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 22, 23, 24, 25, 26, 27, 28, 29, 32, 30, 31, 33, 34, 35, 36, 37, 38, 16, 17, 18, 39, 41, 42, 43, 10, 11, 12, 14, 15, 44, 45, 46, 40}
	for i = 1,#weaponItems do
		local weaponName = getWeaponNameFromID(i)
		dxGridListAddItem(weaponName)
	end
	local dxGridList = getElementByIndex('dx-gridlist-sample')
	addEventHandler('onClientDXClick',dxGridList,
	function(item)
		local text = dxGridListGetItemText(item)
		if text then 
			outputChatBox(text)
		end
	end)
end)