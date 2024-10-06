// set minimum window size
window_set_min_width(room_width)
window_set_min_height(room_height)

// get settings
global.settings = get_settings()
window_set_rectangle(global.settings.windowX, global.settings.windowY,
					global.settings.windowW, global.settings.windowH)