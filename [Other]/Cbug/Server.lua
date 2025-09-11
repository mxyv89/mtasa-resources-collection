local SWeaponData = {
	Glitches = {
		"fastmove",
		"fastfire",
		"crouchbug",
	},
	Skills = {
		"poor",
		"std",
		"pro"
	},
	Settings = {
		"Deagle",
		"Sniper"
	}
}

function setWeaponFlag(weaponID,skill,flag)
	local flags = getWeaponProperty(weaponID,skill,"flags")
	if (not bitTest(flags,flag)) then 
		setWeaponProperty(weaponID,skill,"flags",flag)
	end
end

addEventHandler("onResourceStart",resourceRoot,
	function()
		-- // Getting weapon settings
		for settingID = 1,#SWeaponData.Settings do 
			local settingName = SWeaponData.Settings[settingID]
			local settingValue = get(settingName)
			local weaponID = getWeaponIDFromName(settingName)
			-- // Setting weapon flags
			for skillID = 1,#SWeaponData.Skills do 
				local weaponSkill = SWeaponData.Skills[skillID]
				setWeaponFlag(weaponID,weaponSkill,0x000010)
				setWeaponFlag(weaponID,weaponSkill,0x000020)
			end
			SWeaponData.Settings[settingID] = nil
			SWeaponData.Settings[weaponID] = tonumber(settingValue)
		end
		-- // Setting glitches
		for glitchID = 1,#SWeaponData.Glitches do 
			local glitchName = SWeaponData.Glitches[glitchID]
			setGlitchEnabled(glitchName,true)
		end
end)

addEvent("onSendWeaponData",true)
addEventHandler("onSendWeaponData",root,
	function()
		triggerClientEvent(source,"onRequestWeaponData",source,SWeaponData.Settings)
end)

addEvent("onPlayerSetAmmo",true)
addEventHandler("onPlayerSetAmmo",root,
	function(weaponID,totalAmmo,ammoInClip)
		setWeaponAmmo(source,weaponID,totalAmmo,ammoInClip)
end)