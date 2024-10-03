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
if (global.currentmod != "")
	currentmodLabel.text = "Current Mod: " + global.currentmod
else
	currentmodLabel.text = "No Mod Currently Installed"