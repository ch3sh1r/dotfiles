hl.config({
	input = {
		kb_layout = "us, ru",
		-- Caps is Escape, so Caps Lock lives on both Shifts; the _cancel variant
		-- releases it on the next lone Shift so a misfire clears itself.
		kb_options = "grp:alt_shift_toggle,caps:escape,compose:menu,shift:both_capslock_cancel",
		repeat_rate = 40,
		repeat_delay = 250,
		follow_mouse = 1,
		mouse_refocus = false,
		touchpad = {
			natural_scroll = true,
		},
	},

	general = {
		gaps_in = 2,
		gaps_out = 2,
		border_size = 1,
		col = {
			active_border = { colors = { "rgb(784b84)", "rgb(311432)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	ecosystem = {
		no_update_news = true,
	},

	decoration = {
		rounding = 2,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		disable_scale_notification = true,
		key_press_enables_dpms = true,
		mouse_move_enables_dpms = false,
		focus_on_activate = true,
		on_focus_under_fullscreen = 1,
		anr_missed_pings = 3,
		-- Let a restarted qs re-acquire the session lock (Lock.qml recoverLock).
		allow_session_lock_restore = true,
	},

	cursor = {
		no_hardware_cursors = true,
		hide_on_key_press = true,
	},
})
