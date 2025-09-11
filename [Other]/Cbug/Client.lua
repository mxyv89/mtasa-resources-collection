local CWeaponSettings = {}
local unblockTimer = {}

addEvent("onRequestWeaponData",true)
addEventHandler("onRequestWeaponData",root,
	function(SWeaponSettings)
		CWeaponSettings = SWeaponSettings
end)

addEventHandler("onClientResourceStart",resourceRoot,
	function()
		triggerServerEvent("onSendWeaponData",localPlayer)
end)

addEventHandler("onClientPlayerWeaponFire",localPlayer,
	function(weaponID)
		if CWeaponSettings[weaponID] then
			local blockTime = CWeaponSettings[weaponID]
			if blockTime > 0 then
				toggleControl("fire",false)
				unblockTimer[weaponID] = setTimer(function()
					if isControlEnabled("fire") == false then 
						local _weaponID = getPedWeapon(localPlayer)
						if _weaponID == weaponID then
							toggleControl("fire",true)
						end
					end
					unblockTimer[weaponID] = nil
				end,blockTime,1)
			end
		end
end)

addEventHandler("onClientPlayerWeaponSwitch",localPlayer,
	function()
		local weaponID = getPedWeapon(localPlayer)
		if isControlEnabled("fire") == false then 
			if unblockTimer[weaponID] == nil then 
				toggleControl("fire",true)
			end
		else
			if unblockTimer[weaponID] then 
				toggleControl("fire",false)
			end
		end
end)

addEventHandler("onClientKey",root,
	function(key,pressed)
		if key == "c" and pressed then
			if getKeyState("W") or getKeyState("A") or getKeyState("S") or getKeyState("D") then
				local weaponID = getPedWeapon(localPlayer)
				if CWeaponSettings[weaponID] then
					local currSlot = getPedWeaponSlot(localPlayer)
					local totalAmmo = getPedTotalAmmo(localPlayer)
					local clipAmmo = getPedAmmoInClip(localPlayer)
					if weaponID == 24 then 
						if clipAmmo == 0 then 
							return
						end
					elseif weaponID == 34 then 
						triggerServerEvent("onPlayerSetAmmo",localPlayer,weaponID,totalAmmo,1)
					end
					setPedWeaponSlot(localPlayer,0)
					setPedWeaponSlot(localPlayer,currSlot)
				end
			end
		end
end)