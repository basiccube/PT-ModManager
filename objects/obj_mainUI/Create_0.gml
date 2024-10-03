#macro MOD_DIR directory_get_current_working() + "Mods\\" + global.modselected + "\\"

#macro buttonX room_width - 184
#macro optionsButtonY room_height - 72

mod_arr = get_mods()

ini_open("config.ini")
// temporary
global.gamedir = ini_read_string("ModManager", "GameDir", "C:/Program Files (x86)/Steam/steamapps/common/Pizza Tower/")
global.modselected = ""
global.patchlog = ""
global.currentmod = ini_read_string("ModManager", "CurrentMod", "")
ini_close()

container = new EmuCore(8, 8, room_width, room_height)

launchButton = new EmuButton(buttonX, EMU_AUTO, 160, 48, "Launch!", function()
{
	if (global.modselected == "")
	{
		if (global.currentmod != "")
		{
			launch_game()
			exit;
		}
		
		create_questiondialog("No Mod Selected", "You haven't selected a mod yet. Do you want to launch the game unmodded?", function()
		{
			launch_game()
			self.root.Close()
		},
		function()
		{
			self.root.Close()
		})
		exit;
	}
	
	if (!directory_exists(working_directory + "fullbackup"))
	{
		create_messagedialog("No Backup", "You haven't made a backup yet!")
		exit;
	}
	
	// Get mod files
	var _patch_arr = get_mod_files("xdelta")
	var _lang_arr = get_mod_files("txt", true)
	var _bank_arr = get_mod_files("bank", true)
	var _dll_arr = get_mod_files("dll", true)
	var _video_arr = get_mod_files("mp4", true)
	
	// Files to patch
	var _filestopatch = ["data.win", "PizzaTower.exe", "sound/Desktop/Master.bank", "sound/Desktop/Master.strings.bank", "sound/Desktop/Music.bank", "sound/Desktop/sfx.bank"]
	
	if (!directory_exists(working_directory + "temp"))
		directory_create(working_directory + "temp")
	
	var _failed = false
	for (var i = 0; i < array_length(_patch_arr); i++)
	{
		if (_failed)
			break
		
		var _patch = _patch_arr[i]
		
		for (var j = 0; j < array_length(_filestopatch); j++)
		{
			var _file = global.gamedir + _filestopatch[j]
			var _newfile = working_directory + "temp/" + string_replace(_file, global.gamedir, "")
			
			show_debug_message("Source file: " + _file)
			show_debug_message("Patch file: " + _patch)
			show_debug_message("New file: " + _newfile)
			
			var _patchresult = patch_file(_file, _patch, _newfile)
			if (_patchresult == xdeltaresult.success)
			{
				array_delete(_filestopatch, j, 1)
				break
			}
			else
			{
				_failed = true
				var _str = ""
				switch _patchresult
				{
					case xdeltaresult.notfound:
						var _file_arr = [_file, _patch, _newfile]
						var _filestr = ""
				
						for (var i = 0; i < array_length(_file_arr); i++)
						{
							if (string_pos(_file_arr[i], global.patchlog) != 0)
								_filestr = _file_arr[i]
						}
				
						_str = "Cannot find the following file: " + _filestr
						break
					case xdeltaresult.checksum:
						_str = "Checksum mismatch. Please make sure that the patch is compatible with the version of the game you are using."
						break
					case xdeltaresult.accessdenied:
						_str = "Access is denied. Make sure you have the permissions required to be able to access the game directory or try running the mod manager as an administrator."
						break
					case xdeltaresult.invalidpatch:
						_str = "Invalid patch. Please make sure that the patch file is a valid patch."
						break
					case xdeltaresult.fileexists:
						_str = "Patched file already exists.\nA previous patching process might have broken in some way, please check the temp folder if it exists and delete it."
						break
				}
				create_messagedialog("Patch Failed", "Failed to patch due to the following reason:\n" + _str + "\nCheck xdelta.log for any more technical details.")
			}
			
			if (_failed)
				break
		}
	}
	
	if (!_failed)
	{
		// Copy patched files
		var _temp_arr = get_folder_array(working_directory + "temp")
		var _copyfailed = false
		
		for (var i = 0; i < array_length(_temp_arr); i++)
		{
			var _tempfile = _temp_arr[i]
			var _copyresult = file_replace(working_directory + "temp/" + _tempfile, global.gamedir + _tempfile)
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy language files
		for (var i = 0; i < array_length(_lang_arr); i++)
		{
			var _langfile = _lang_arr[i]
			var _copyresult = file_replace(MOD_DIR + _langfile, global.gamedir + "lang/" + filename_name(_langfile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy FMOD bank files
		for (var i = 0; i < array_length(_bank_arr); i++)
		{
			var _bankfile = _bank_arr[i]
			var _copyresult = file_replace(MOD_DIR + _bankfile, global.gamedir + "sound/Desktop/" + filename_name(_bankfile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy DLLs
		for (var i = 0; i < array_length(_dll_arr); i++)
		{
			var _dllfile = _dll_arr[i]
			var _copyresult = file_replace(MOD_DIR + _dllfile, global.gamedir + filename_name(_dllfile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy MP4 videos
		for (var i = 0; i < array_length(_video_arr); i++)
		{
			var _videofile = _video_arr[i]
			var _copyresult = file_replace(MOD_DIR + _videofile, global.gamedir + filename_name(_videofile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		if (_copyfailed)
			create_messagedialog("Failed To Install", "Failed to copy mod files.")
		else
		{
			launch_game()
			global.currentmod = global.modselected
			
			ini_open("config.ini")
			ini_write_string("ModManager", "CurrentMod", global.currentmod)
			ini_close()
		}
	}
	
	directory_destroy(working_directory + "temp")
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
	},
	function()
	{
		self.root.Close()
	})
})
completebackupButton = new EmuButton(buttonX, EMU_AUTO, 160, 48, "Full backup", function()
{
	if (global.currentmod != "")
	{
		create_messagedialog("Cannot Make Backup", "You cannot make a backup while a mod is installed. Restore your backup and then try again.")
		exit;
	}
	
	var _text = "Do you want to make a complete game backup?"
	if (directory_exists(working_directory + "fullbackup"))
	{
		//if (global.currentmod != "")
		//	_text = "You already have a complete backup.\nDo you want to replace your existing backup?\n\nNOTE:\nA mod is currently installed.\nIf the backup is a clean copy of the game then it will replace it with your currently modded one!"
		//else
		_text = "You already have a complete backup.\nDo you want to replace your existing backup?"
	}
	
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
	},
	function()
	{
		self.root.Close()
	})
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
		show_debug_message("Selected: " + _sel)
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
