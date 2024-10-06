launchButton.x = buttonX
restoreButton.x = buttonX
optionsButton.x = buttonX
optionsButton.y = optionsButtonY
completebackupButton.x = buttonX
modList.width = buttonX - 24
modList.height = floor(room_height - 48)
modList.slots = floor(modList.height / 52)
currentmodLabel.y = room_height - 48
currentmodLabel.width = buttonX - 20
if (global.settings.currentMod != "")
	currentmodLabel.text = "Current Mod: " + global.settings.currentMod
else
	currentmodLabel.text = "No Mod Currently Installed"
	
if (firstrunDialog != -4 && global.settings.firstRun)
{
	if (global.settings.gameDir != "")
	{
		firstrunDirLabel.text = global.settings.gameDir
		firstrunOKButton.interactive = true
	}
	else
	{
		firstrunDirLabel.text = "(no game directory specified)"
		firstrunOKButton.interactive = false
	}
}