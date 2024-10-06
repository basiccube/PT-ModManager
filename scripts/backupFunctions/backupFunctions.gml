function backup_file(_file)
{
	file_copy(global.settings.gameDir + _file, "backup/" + _file)
}

function backup_game_files()
{
	if (directory_exists(working_directory + "fullbackup"))
		directory_destroy(working_directory + "fullbackup")
	
	return directory_copy(global.settings.gameDir, working_directory + "fullbackup/");
}

function restore_file(_file)
{
	file_copy("backup/" + _file, global.settings.gameDir + _file)
}

function restore_game_files()
{
	if (!directory_exists(working_directory + "fullbackup"))
		exit;
		
	print("Deleting previous game directory...")
	directory_destroy(global.settings.gameDir)
		
	// Apparently something as simple as directory_copy doesn't work here so this has to be done instead
	
	var _arr = []
	var _dir = directory_contents_first(working_directory + "fullbackup", "*.*", true, true)
	
	while (_dir != "")
	{
		var _newdir = string_replace(_dir, working_directory + "fullbackup\\", "")
		
		array_push(_arr, _newdir)
		_dir = directory_contents_next()
	}
	
	directory_contents_close()
	
	global.settings.currentMod = ""
	save_settings()
	
	print("Restoring game backup...")
	directory_create(global.settings.gameDir)
	
	for (var i = 0; i < array_length(_arr); i++)
	{
		var _file = _arr[i]
		file_copy(working_directory + "fullbackup/" + _file, global.settings.gameDir + _file)
	}
}