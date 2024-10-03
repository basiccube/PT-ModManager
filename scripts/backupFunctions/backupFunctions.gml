function backup_file(_file)
{
	file_copy(global.gamedir + _file, "backup/" + _file)
}

function backup_game_files()
{
	if (directory_exists(working_directory + "fullbackup"))
		directory_destroy(working_directory + "fullbackup")
	
	return directory_copy(global.gamedir, working_directory + "fullbackup/");
}

function restore_file(_file)
{
	file_copy("backup/" + _file, global.gamedir + _file)
}

function restore_game_files()
{
	if (!directory_exists(working_directory + "fullbackup"))
		exit;
		
	directory_destroy(global.gamedir)
		
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
	
	global.currentmod = ""
	ini_open("config.ini")
	ini_write_string("ModManager", "CurrentMod", "")
	ini_close()
	
	directory_create(global.gamedir)
	
	for (var i = 0; i < array_length(_arr); i++)
	{
		var _file = _arr[i]
		file_copy(working_directory + "fullbackup/" + _file, global.gamedir + _file)
	}
}