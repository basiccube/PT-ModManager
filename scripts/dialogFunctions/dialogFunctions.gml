function create_messagedialog(_title, _text, _callback = emu_dialog_close_auto)
{
	var _width = string_width(_text) - 250
	var _dialogwidth = _width
	var _height = 32 * string_count("\n", _text)
	
	if (_width < 600)
		_width = 600
	if (_dialogwidth < 640)
		_dialogwidth = 640
	
	var _dialog = new EmuDialog(_width, 160 + _height, _title)
	var _label = new EmuText(16, 16, _width - 16, 160 + _height, _text)
	var _button = new EmuButton((_dialog.width / 2) - (160 / 2), _dialog.height - 48 - (48 / 2), 160, 48, "OK", _callback)
	
	_label.align.v = fa_top
	_dialog.AddContent(_label)
	_dialog.AddContent(_button)
	_dialog.CenterInWindow()
}

function create_questiondialog(_title, _text, _yescallback, _nocallback)
{
	var _width = string_width(_text) - 250
	var _dialogwidth = _width
	var _height = 32 * string_count("\n", _text)
	
	if (_width < 600)
		_width = 600
	if (_dialogwidth < 640)
		_dialogwidth = 640
	
	var _dialog = new EmuDialog(_width, 160 + _height, _title)
	var _label = new EmuText(16, 16, _width - 16, 160 + _height, _text)
	var _yesbutton = new EmuButton((_dialog.width / 2) - 160 - 4, _dialog.height - 48 - (48 / 2), 160, 48, "Yes", _yescallback)
	var _nobutton = new EmuButton((_dialog.width / 2) + 4, _dialog.height - 48 - (48 / 2), 160, 48, "No", _nocallback)
	
	_label.align.v = fa_top
	_dialog.AddContent(_label)
	_dialog.AddContent(_yesbutton)
	_dialog.AddContent(_nobutton)
	_dialog.CenterInWindow()
}