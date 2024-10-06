enum xdeltaresult
{
	notfound,
	checksum,
	invalidpatch,
	accessdenied,
	fileexists,
	success,
}

function get_xdelta_result(_outstr)
{
	// Try to get the error encountered during the patching process
	// yes this is a pretty shitty way to do it but fuck it
	if (string_pos("cannot find the file", _outstr) != 0)
		return xdeltaresult.notfound;
	if (string_pos("Access is denied", _outstr) != 0)
		return xdeltaresult.accessdenied;
	if (string_pos("target window checksum mismatch", _outstr) != 0)
		return xdeltaresult.checksum;
	if (string_pos("source file too short", _outstr) != 0)
		return xdeltaresult.checksum;
	if (string_pos("not a VCDIFF input", _outstr) != 0)
		return xdeltaresult.invalidpatch;
	if (string_pos("address too large", _outstr) != 0)
		return xdeltaresult.invalidpatch;
	if (string_pos("to overwrite output file", _outstr) != 0)
		return xdeltaresult.fileexists;
	
	// if the above fails, resort to trying to get the error this way
	if (string_pos("XD3_INVALID_INPUT", _outstr) != 0)
		return xdeltaresult.invalidpatch;
	
	
	return xdeltaresult.success;
}

function patch_file(_oldfile, _patchfile, _newfile)
{
	var _proc = ProcessExecute("xdelta.exe -d -s " + "\"" + _oldfile + "\" " + "\"" + _patchfile + "\" " + "\"" + _newfile + "\"")
	var _procout = ExecutedProcessReadFromStandardOutput(_proc)
	print(_procout)
	
	var _log = file_text_open_write("xdelta.log")
	file_text_write_string(_log, _procout)
	file_text_close(_log)
	global.patchlog = _procout
	
	return get_xdelta_result(_procout);
}

function patch_selected_mod(_launch = true)
{
	print("Installing mod ", global.modselected)
	
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
	var _successes = 0
	var _str = ""
	for (var i = 0; i < array_length(_patch_arr); i++)
	{
		var _patch = _patch_arr[i]
		for (var j = 0; j < array_length(_filestopatch); j++)
		{
			var _file = global.settings.gameDir + _filestopatch[j]
			var _newfile = working_directory + "temp/" + string_replace(_file, global.settings.gameDir, "")
			
			print("Source file: ", _file)
			print("Patch file: ", _patch)
			print("New file: ", _newfile)
			
			var _patchresult = patch_file(_file, _patch, _newfile)
			if (_patchresult == xdeltaresult.success)
			{
				array_delete(_filestopatch, j, 1)
				_successes++
				break
			}
			else
			{
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
						_str = "Checksum mismatch. Please make sure that the patch is compatible with the version of the game you are using\nand that you aren't trying to install the mod on top of the mod."
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
				print("Patch error: ", _str)
			}
		}
	}
	
	if (_successes >= array_length(_patch_arr))
	{
		print("Everything appears to have been patched successfully, continuing...")
		_failed = false
	}
	else
	{
		create_messagedialog("Patch Failed", "Failed to patch due to the following reason:\n" + _str + "\nCheck xdelta.log for any more technical details.")
		_failed = true
	}
	
	if (!_failed)
	{
		// Copy patched files
		var _temp_arr = get_folder_array(working_directory + "temp")
		var _copyfailed = false
		
		for (var i = 0; i < array_length(_temp_arr); i++)
		{
			var _tempfile = _temp_arr[i]
			var _copyresult = file_replace(working_directory + "temp/" + _tempfile, global.settings.gameDir + _tempfile)
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy language files
		for (var i = 0; i < array_length(_lang_arr); i++)
		{
			var _langfile = _lang_arr[i]
			var _copyresult = file_replace(MOD_DIR + _langfile, global.settings.gameDir + "lang/" + filename_name(_langfile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy FMOD bank files
		for (var i = 0; i < array_length(_bank_arr); i++)
		{
			var _bankfile = _bank_arr[i]
			var _copyresult = file_replace(MOD_DIR + _bankfile, global.settings.gameDir + "sound/Desktop/" + filename_name(_bankfile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy DLLs
		for (var i = 0; i < array_length(_dll_arr); i++)
		{
			var _dllfile = _dll_arr[i]
			var _copyresult = file_replace(MOD_DIR + _dllfile, global.settings.gameDir + filename_name(_dllfile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		// Copy MP4 videos
		for (var i = 0; i < array_length(_video_arr); i++)
		{
			var _videofile = _video_arr[i]
			var _copyresult = file_replace(MOD_DIR + _videofile, global.settings.gameDir + filename_name(_videofile))
			if (!_copyresult)
				_copyfailed = true
		}
		
		if (_copyfailed)
			create_messagedialog("Failed To Install", "Failed to copy mod files.")
		else
		{
			if (_launch)
				launch_game()
			else
				create_messagedialog("Mod Installed", "The mod has been successfully installed onto your game.")
			global.settings.currentMod = global.modselected
			save_settings()
		}
	}
	
	directory_destroy(working_directory + "temp")
}

function launch_game()
{
	execute_program(global.settings.gameDir + "PizzaTower.exe", "", false)
}