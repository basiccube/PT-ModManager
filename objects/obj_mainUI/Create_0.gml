#macro MOD_DIR directory_get_current_working() + "Mods\\" + global.modselected + "\\"

#macro buttonX room_width - 184
#macro optionsButtonY room_height - 72

mod_arr = get_mods()

global.modselected = ""
global.patchlog = ""

var _log = file_text_open_append(working_directory + "modmanager.log")
file_text_write_string(_log, "\n=======================================================================\n")
file_text_write_string(_log, "MOD MANAGER STARTED AT: " + date_datetime_string(date_current_datetime()) + "\n")
file_text_write_string(_log, "=======================================================================\n")
file_text_close(_log)

container = new EmuCore(8, 8, room_width, room_height)

launchButton = new EmuButton(buttonX, EMU_AUTO, 160, 48, "Launch!", function()
{
	if (global.modselected == "")
	{
		if (global.settings.currentMod != "")
		{
			launch_game()
			exit;
		}
		
		create_questiondialog("No Mod Selected", "You haven't selected a mod yet. Do you want to launch the game unmodded?", function()
		{
			launch_game()
			self.root.Close()
		}, emu_dialog_close_auto)
		exit;
	}
	
	if (!directory_exists(working_directory + "fullbackup"))
	{
		create_messagedialog("No Backup", "You haven't made a backup yet!")
		exit;
	}
	
	patch_selected_mod(true)
})
restoreButton = new EmuButton(buttonX, EMU_AUTO, 160, 48, "Restore backup", function()
{
	if (!directory_exists(working_directory + "fullbackup"))
	{
		create_messagedialog("No Backup", "You don't have a game backup to restore.")
		exit;
	}
	
	create_questiondialog("Restore Complete Backup", "Do you want to restore your game backup?\nNOTE: This will delete all files in your game folder!", function()
	{
		restore_game_files()
		
		setTimeout(function()
		{
			create_messagedialog("Restore Done", "Your game has been restored.")
		}, 2)
		
		self.root.Close()
	}, emu_dialog_close_auto)
})
completebackupButton = new EmuButton(buttonX, EMU_AUTO, 160, 48, "Full backup", function()
{
	if (global.settings.currentMod != "")
	{
		create_messagedialog("Cannot Make Backup", "You cannot make a backup while a mod is installed. Restore your backup and then try again.")
		exit;
	}
	
	var _text = "Do you want to make a complete game backup?"
	if (directory_exists(working_directory + "fullbackup"))
		_text = "You already have a complete backup.\nDo you want to replace your existing backup?"
	
	create_questiondialog("Make Complete Backup", _text, function()
	{
		var _backupresult = backup_game_files()
		
		setTimeout(function()
		{
			if (arguments[0])
				create_messagedialog("Backup Success", "Game has been succesfully backed up.")
			else
				create_messagedialog("Backup Failure", "Game backup failed.")
		}, 2, _backupresult)
		
		self.root.Close()
	}, emu_dialog_close_auto)
})
optionsButton = new EmuButton(buttonX, optionsButtonY, 160, 48, "Settings", function()
{
	create_messagedialog("", "Unimplemented")
})
modList = new EmuListNew(8, 16, buttonX - 20, 50, 10, function()
{
	var _sel = GetSelectedItem()
	if (_sel == undefined)
		global.modselected = ""
	else
	{
		global.modselected = _sel
		print("Selected: ", _sel)
	}
})
modList.AddEntries(mod_arr)
currentmodLabel = new EmuText(0, room_height - 48, buttonX - 20, 24, "No Mod Currently Installed")

container.AddContent(launchButton)
container.AddContent(restoreButton)
container.AddContent(completebackupButton)
container.AddContent(optionsButton)
container.AddContent(modList)
container.AddContent(currentmodLabel)

firstrunDialog = -4
firstrunDirectory = ""
if (global.settings.firstRun)
{	
	print("First launch - open welcome dialog")
	firstrunDialog = new EmuDialog(720, 480, "Welcome to PT-ModManager!")
	firstrunLabel = new EmuText(16, 16, 704, 96, "First you need to specify where your game directory is.\nPress the Browse button to do that.")
	firstrunDirLabel = new EmuText(16, 80, 680, 384, "(no game directory specified)")
	firstrunOKButton = new EmuButton((firstrunDialog.width / 2) - (160 / 2), firstrunDialog.height - 48 - (48 / 2), 160, 48, "OK", function()
	{
		if (!file_exists(global.settings.gameDir + "data.win"))
		{
			create_questiondialog("No Game Found", "There doesn't appear to be a valid game here that\ncan be used with PT-ModManager.\nAre you sure you still want to continue?", function()
			{
				self.root.Close()
				obj_mainUI.firstrunDialog.Close()
				global.settings.firstRun = false
				print("Specified game directory: ", global.settings.gameDir)
				save_settings()
			}, emu_dialog_close_auto)
			exit;
		}
		
		self.root.Close()
		global.settings.firstRun = false
		print("Specified game directory: ", global.settings.gameDir)
		save_settings()
	})
	firstrunBrowseButton = new EmuButton((firstrunDialog.width / 2) - (160 / 2), firstrunDialog.height - 104 - (48 / 2), 160, 48, "Browse", function()
	{
		var _dialogresult = get_open_filename_ext("Pizza Tower executable|*.exe", "", working_directory, "Locate game executable")
		if (_dialogresult != "")
			global.settings.gameDir = filename_dir(_dialogresult) + "\\"
	})
	
	firstrunLabel.align.v = fa_top
	firstrunDirLabel.align.v = fa_top
	firstrunOKButton.interactive = false
	firstrunDialog.AddContent(firstrunLabel)
	firstrunDialog.AddContent(firstrunDirLabel)
	firstrunDialog.AddContent(firstrunOKButton)
	firstrunDialog.AddContent(firstrunBrowseButton)
	firstrunDialog.close_button = false
	firstrunDialog.CenterInWindow()
}
