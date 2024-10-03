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
		show_debug_message("Deleting file " + _newname)
		file_delete(_newname)
	}
			
	show_debug_message("Copying file " + _fname)
	return file_copy(_fname, _newname);
}