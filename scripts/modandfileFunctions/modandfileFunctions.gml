function get_mods()
{
	// Get mod list
	var _arr = []
	var _dir = directory_contents_first("Mods", "*.*", true, false)
	
	while (_dir != "")
	{
		if (file_exists(_dir + "\\mod.json"))
		{
			var _newdir = string_delete(_dir, string_length(_dir), 1)
			_newdir = string_replace(_newdir, working_directory + "Mods\\", "")
		
			array_push(_arr, _newdir)
		}
		_dir = directory_contents_next()
	}
	
	directory_contents_close()
	return _arr;
}

function get_mod_files(_fileext, _nodir = false)
{
	// Get files with specified file extension from selected mod
	var _arr = []
	var _dir = directory_contents_first("Mods/" + global.modselected, "*." + _fileext, true, true)
	
	while (_dir != "")
	{
		var _newdir = _dir
		if (_nodir)
			_newdir = string_replace(_dir, MOD_DIR, "")
		
		array_push(_arr, _newdir)
		_dir = directory_contents_next()
	}
	
	directory_contents_close()
	
	// Delete folder path in array if it exists
	if (array_length(_arr) > 0 && string_pos("." + _fileext, _arr[0]) == 0)
		array_delete(_arr, 0, 1)
	
	return _arr;
}

function get_folder_array(_directory)
{
	var _arr = []
	var _dir = directory_contents_first(_directory, "*.*", true, true)
	
	while (_dir != "")
	{
		var _newdir = string_replace(_dir, _directory + "\\", "")
		
		array_push(_arr, _newdir)
		_dir = directory_contents_next()
	}
	
	directory_contents_close()
	return _arr;
}

function file_replace(_fname, _newname)
{
	if (file_exists(_newname))
	{
		print("Deleting file ", _newname)
		file_delete(_newname)
	}
			
	print("Copying file ", _fname)
	return file_copy(_fname, _newname);
}

function print()
{
	var _string = ""
	for (var i = 0; i < argument_count; i++)
		_string += string(argument[i])
		
	var _log = file_text_open_append(working_directory + "modmanager.log")
	file_text_write_string(_log, _string + "\n")
	file_text_close(_log)
	
	show_debug_message(_string)
	exit;
}

function get_settings()
{
	if (file_exists(working_directory + "config.json"))
	{
		var _settingsfile = file_text_open_read(working_directory + "config.json")
		var _settingsjson = json_parse(file_text_read_all(_settingsfile))
		file_text_close(_settingsfile)
		
		return _settingsjson;
	}
	
	return
	{
		windowW : window_get_width(),
		windowH : window_get_height(),
		windowX : (display_get_width() / 2) - (window_get_width() / 2),
		windowY : (display_get_height() / 2) - (window_get_height() / 2),
		currentMod : "",
		gameDir : "",
		firstRun : true,
	};
}

function save_settings()
{
	print("Saving settings")
	global.settings.windowX = window_get_x()
	global.settings.windowY = window_get_y()
	global.settings.windowW = window_get_width()
	global.settings.windowH = window_get_height()

	var _jsonstr = json_stringify(global.settings)
	var _jsonfile = file_text_open_write(working_directory + "config.json")
	file_text_write_string(_jsonfile, _jsonstr)
	file_text_close(_jsonfile)
}