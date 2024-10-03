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
	if (string_pos("to overwrite output file", _outstr) != 0)
		return xdeltaresult.fileexists;
	
	return xdeltaresult.success;
}

function patch_file(_oldfile, _patchfile, _newfile)
{
	var _proc = ProcessExecute("xdelta.exe -d -s " + "\"" + _oldfile + "\" " + "\"" + _patchfile + "\" " + "\"" + _newfile + "\"")
	var _procout = ExecutedProcessReadFromStandardOutput(_proc)
	show_debug_message(_procout)
	
	var _log = file_text_open_write("xdelta.log")
	file_text_write_string(_log, _procout)
	file_text_close(_log)
	global.patchlog = _procout
	
	return get_xdelta_result(_procout);
}

function launch_game()
{
	execute_program(global.gamedir + "PizzaTower.exe", "", false)
}