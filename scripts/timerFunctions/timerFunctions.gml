/// @function setTimeout( _func, _time, _args )
/// @argument {function} func - The callback to invoke after "_time" has passed
/// @argument {number} time - The amount of milliseconds to wait to fire the callback
/// @argument {...any} args - Any arguments to pass into the callback when fired
/// @returns {number} The numerical ID corresponding to the timeout
function setTimeout( _func, _time )
{
	var _getArguments = undefined
	if (argument_count - 2 > 0)
	{
		_getArguments = array_create(argument_count - 2)
		for (var i = 2; i < argument_count; i++)
			_getArguments[i - 2] = argument[i]
	}
	
	ds_list_add(global.__TIMEOUT_LIST__,
	{
		Index: global.__TIMEOUT_INDEX__,
		Callback: _func,
		Arguments: _getArguments,
		Timestamp: current_time,
		Time: _time,
	})
	return global.__TIMEOUT_INDEX__++;
}

/// @function clearTimeout( _ind )
/// @argument {number} ind - The index of the timeout to clear
/// @returns {bool} - If the timeout was removed or not
function clearTimeout( _ind )
{
	for (var i = 0, _i = ds_list_size(global.__TIMEOUT_LIST__); i < _i; i++)
	{
		if (global.__TIMEOUT_LIST__[| i].Index == _ind)
		{
			ds_list_delete(global.__TIMEOUT_LIST__, i)
			return true;
		}
	}
	return false;
}

/// @function setInterval( _func, _time, _args )
/// @argument {function} func - The callback to invoke every "_time" miliseconds
/// @argument {number} time - The amount of milliseconds to wait to fire the callback
/// @argument {...any} args - Any arguments to pass into the callback when fired
/// @returns {number} The numerical ID corresponding to the interval
function setInterval( _func, _time )
{
	var _getArguments = undefined
	if (argument_count - 2 > 0)
	{
		_getArguments = array_create(argument_count - 2)
		for(var i = 2; i < argument_count; i++)
			_getArguments[i - 2] = argument[i]
	}
	
	ds_list_add(global.__INTERVAL_LIST__,
	{
		Index: global.__INTERVAL_INDEX__,
		Callback: _func,
		Arguments: _getArguments,
		Timestamp: current_time,
		Time: _time,
	})
	return global.__INTERVAL_INDEX__++;
}

/// @function clearInterval( _ind )
/// @argument {number} ind - The index of the interval to clear
/// @returns {bool} - If the interval was removed or not
function clearInterval( _ind )
{
	for (var i = 0, _i = ds_list_size(global.__INTERVAL_LIST__); i < _i; i++)
	{
		if (global.__INTERVAL_LIST__[| i].Index == _ind)
		{
			ds_list_delete(global.__INTERVAL_LIST__, i)
			return true;
		}
	}
	return false;
}

global.__INTERVAL_LIST__ = ds_list_create()
global.__INTERVAL_INDEX__ = 0
function __INTERVAL_UPDATE__()
{
	for (var i = 0, _i = ds_list_size(global.__INTERVAL_LIST__); i < _i; i++)
	{
		with (global.__INTERVAL_LIST__[| i])
		{
			if (current_time - Timestamp >= Time)
			{
				method({arguments: Arguments}, Callback)()
				Timestamp = current_time
			}
		}
	}
}

global.__TIMEOUT_LIST__ = ds_list_create()
global.__TIMEOUT_INDEX__ = 0
function __TIMEOUT_UPDATE__()
{
	for (var i = 0; i < ds_list_size(global.__TIMEOUT_LIST__); i++)
	{
		with (global.__TIMEOUT_LIST__[| i])
		{
			if (current_time - Timestamp >= Time)
			{
				method({arguments: Arguments}, Callback)()
				ds_list_delete(global.__TIMEOUT_LIST__, i--)
			}
		}
	}
}